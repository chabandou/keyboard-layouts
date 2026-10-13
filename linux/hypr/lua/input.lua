-- Input Configuration
local home = os.getenv("HOME") or ""

hl.config({
    input = {
        kb_layout = "custom,ara", -- EN Colemak-DH + Arabic; toggle via SUPER ALT+K
        kb_variant = "cmk_ed_dh_wide_full,",
        resolve_binds_by_sym = true,
        kb_options = "lv3:ralt_switch",
        kb_model = "pc104awide",
        repeat_rate = 40,
        repeat_delay = 600,
        numlock_by_default = false,
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = {
            natural_scroll = true,
            clickfinger_behavior = true,
            scroll_factor = 0.4,
            disable_while_typing = false,
            drag_3fg = true,
        },
    },
    xwayland = {
        force_zero_scaling = true,
    },
    ecosystem = {
        no_update_news = true,
    },
})
