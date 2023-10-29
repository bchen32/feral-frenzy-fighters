#include "ggpo_multiplayer.h"
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/classes/random_number_generator.hpp>
#include <godot_cpp/classes/input.hpp>
#include <godot_cpp/classes/input_map.hpp>
#include <godot_cpp/classes/node2d.hpp>

using namespace godot;

GGPOSessionCallbacks GGPOMultiplayer::GGPO_CALLBACKS {
    .begin_game = &begin_game,
    .save_game_state = &save_game_state,
    .load_game_state = &load_game_state,
    .log_game_state = &log_game_state,
    .free_buffer = &free_buffer,
    .advance_frame = &advance_frame,
    .on_event = &on_event
};

/*
 * Simple checksum function stolen from wikipedia:
 *
 *   http://en.wikipedia.org/wiki/Fletcher%27s_checksum
 */

int
fletcher32_checksum(short *data, size_t len)
{
    int sum1 = 0xffff, sum2 = 0xffff;

    while (len) {
        size_t tlen = len > 360 ? 360 : len;
        len -= tlen;
        do {
            sum1 += *data++;
            sum2 += sum1;
        } while (--tlen);
        sum1 = (sum1 & 0xffff) + (sum1 >> 16);
        sum2 = (sum2 & 0xffff) + (sum2 >> 16);
    }

    /* Second reduction step to reduce sums to 16 bits */
    sum1 = (sum1 & 0xffff) + (sum1 >> 16);
    sum2 = (sum2 & 0xffff) + (sum2 >> 16);
    return sum2 << 16 | sum1;
}

GGPOMultiplayer::~GGPOMultiplayer() {
    // Add your cleanup here.
}

void GGPOMultiplayer::_bind_methods() {
    ClassDB::bind_method(D_METHOD("create_peer", "local_port", "num_of_players"), &GGPOMultiplayer::create_peer);
    ClassDB::bind_method(D_METHOD("add_player", "player_ip", "local_port"), &GGPOMultiplayer::add_player);
}

GGPOMultiplayer::GGPOMultiplayer() {
}

void GGPOMultiplayer::_ready() {
}

void GGPOMultiplayer::create_peer(uint32_t local_port, int num_of_players) {
    GGPOSession *ggpo_session;
    GGPOPlayer ggpo_local_player {
        .size = sizeof(GGPOPlayer),
        .type = GGPO_PLAYERTYPE_LOCAL,
        .player_num = 0
    };
    int result;

    result = ggpo_start_session(&ggpo_session, &GGPO_CALLBACKS, GGPO_APP_NAME.data(), num_of_players,
                                sizeof(int), local_port);

    if(result == 0) {
        GGPOPlayerHandle ggpo_player_handle;

        ggpo_set_disconnect_timeout(ggpo_session, 3000);
        ggpo_set_disconnect_notify_start(ggpo_session, 1000);

        m_ggpo_session.reset(ggpo_session);

        result = ggpo_add_player(ggpo_session, &ggpo_local_player, &ggpo_player_handle);

        if(result == 0) {
            m_ggpo_players.push_back(ggpo_player_handle);
        } else {
            print_out_GGPO_error(result, "ggpo_add_player local player");

            m_ggpo_session.reset(nullptr);
        }
    } else {
        print_out_GGPO_error(result, "ggpo_start_session");
    }
}

void GGPOMultiplayer::add_player(String player_ip, uint32_t port) {
    if(m_ggpo_session == nullptr) {
        UtilityFunctions::print("We can't add a player to a GGPOMultiplayer which doesn't have a peer!");
        return;
    }

    GGPOPlayer player {
        .size = sizeof(GGPOPlayer),
        .type = GGPO_PLAYERTYPE_REMOTE,
        .player_num = m_ggpo_players.size(),
    };
    GGPOPlayerHandle player_handle;
    int result;

    player.u.remote.port = static_cast<uint16_t>(port);

    std::memcpy(player.u.remote.ip_address, player_ip.ptr(), std::min(static_cast<uint64_t>(player_ip.length()),
                                                                      sizeof(player.u.remote.ip_address)));

    result = ggpo_add_player(m_ggpo_session.get(), &player, &player_handle);

    if(result == 0) {
        m_ggpo_players.push_back(player_handle);
    } else {
        print_out_GGPO_error(result, "ggpo_add_player remote player");
    }
}

void GGPOMultiplayer::_process(double delta) {
    ggpo_idle(m_ggpo_session.get(), 20);
}

bool GGPOMultiplayer::begin_game(const char *game) {
    // deprecated, not needed
    return true;
}

bool GGPOMultiplayer::save_game_state(unsigned char **buffer, int *len, int *checksum, int frame) {
    assert(current_ggpo_multiplayer != nullptr);
    std::vector<unsigned char> game_state_bytes;

    for(int i = 0; current_ggpo_multiplayer->m_nodes_to_track.size() > i; ++i) {
        Node2D *node2d = Object::cast_to<Node2D>(current_ggpo_multiplayer->m_nodes_to_track[i]);

        assert(node2d != nullptr);

        Vector2 global_pos = node2d->get_global_position();

        std::array<unsigned char, 4> x_bytes = float_to_bytes(global_pos.x);
        std::array<unsigned char, 4> y_bytes = float_to_bytes(global_pos.y);

        game_state_bytes.insert(game_state_bytes.end(), x_bytes.begin(), x_bytes.end());
        game_state_bytes.insert(game_state_bytes.end(), y_bytes.begin(), y_bytes.end());
    }

    *len = game_state_bytes.size() + (game_state_bytes.size() % 2);
    *buffer = new unsigned char[*len];

    std::memcpy(*buffer, game_state_bytes.data(), *len);

    *checksum = fletcher32_checksum(reinterpret_cast<short*>(*buffer), *len);

    frame = current_ggpo_multiplayer->m_frame_counter++;

    return true;
}

bool GGPOMultiplayer::load_game_state(unsigned char *buffer, int len) {
    // 2 vector components consisting of 4 unsigned chars representing a float
    assert(len % (sizeof(unsigned char) * 4 * 2) == 0);

    int buffer_pos = 0;

    for(int i = 0; current_ggpo_multiplayer->m_nodes_to_track.size() > i; ++i) {
        Node2D *node2d = Object::cast_to<Node2D>(current_ggpo_multiplayer->m_nodes_to_track[i]);
        assert(buffer_pos < len);

        float x = float_from_bytes(&buffer[buffer_pos]);
        float y = float_from_bytes(&buffer[buffer_pos + sizeof(float)]);

        node2d->set_global_position(Vector2(x, y));

        buffer_pos += 2 * sizeof(float);
    }
    return true;
}

bool GGPOMultiplayer::log_game_state(char *filename, unsigned char *buffer, int len) {
    // TODO(Bobby): impl this!
    return true;
}

void GGPOMultiplayer::free_buffer(void *buffer) {
    if(buffer != nullptr) {
        delete reinterpret_cast<unsigned char*>(buffer);
    }
}

bool GGPOMultiplayer::advance_frame(int flags) {
    //ggpo_synchronize_input();

    //ggpo_advance_frame();
    return true;
}

bool GGPOMultiplayer::on_event(GGPOEvent *info) {
    // TODO(Bobby): impl this!
    return true;
}

