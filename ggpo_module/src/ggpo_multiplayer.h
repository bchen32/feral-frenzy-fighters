#ifndef BALL_H
#define BALL_H

#include <cassert>
#include <memory>
#include <string_view>
#include <unordered_map>

#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

#include "../ggpo/src/include/ggponet.h"

namespace godot {

class GGPOMultiplayer : public Node {
    GDCLASS(GGPOMultiplayer, Node)
private:
    struct GGPOSessionDeleter {
        void operator()(GGPOSession *session) {
            if(session != nullptr) {
                ggpo_close_session(session);
                current_ggpo_multiplayer = nullptr;
            }
        }
    };

    static GGPOSessionCallbacks GGPO_CALLBACKS;
    static constexpr std::string_view GGPO_APP_NAME = "FFF\0"; // needs to be null terminated for GGPO

    static GGPOMultiplayer *current_ggpo_multiplayer;

    int m_frame_counter;
    std::unique_ptr<GGPOSession, GGPOSessionDeleter> m_ggpo_session;
    std::vector<GGPOPlayerHandle> m_ggpo_players;
    Array m_nodes_to_track;

    // GGPO callbacks
    static bool begin_game(const char *game);
    static bool save_game_state(unsigned char **buffer, int *len, int *checksum, int frame);
    static bool load_game_state(unsigned char *buffer, int len);
    static bool log_game_state(char *filename, unsigned char *buffer, int len);
    static void free_buffer(void *buffer);
    static bool advance_frame(int flags);
    static bool on_event(GGPOEvent *info);

    static std::array<unsigned char, 4> float_to_bytes(float float_to_convert) {
        uint32_t float_uint = static_cast<uint32_t>(float_to_convert);

        return {{
            (float_uint >> 0) & 0x000000FF,
            (float_uint >> 8) & 0x000000FF,
            (float_uint >> 16) & 0x000000FF,
            (float_uint >> 24) & 0x000000FF
        }};
    }

    static float float_from_bytes(const unsigned char *bytes) {
        return static_cast<float>(bytes[0] | (bytes[1] << 8) | (bytes[2] << 16) | (bytes[3] << 24));
    }

    static float float_from_bytes(const std::array<unsigned char, 4> &bytes) {
        return float_from_bytes(bytes.data());
    }

    void print_out_GGPO_error(int ggpo_error, const String &context) {
        UtilityFunctions::print("An error ", ggpo_error, " occurred with ", context, "!");
    }
protected:
    static void _bind_methods();

public:
    GGPOMultiplayer();
    ~GGPOMultiplayer();

    void create_peer(uint32_t local_port, int num_of_players);
    void add_player(String player_ip, uint32_t port);

    void _ready() override;
    void _process(double delta) override;
};

}

#endif