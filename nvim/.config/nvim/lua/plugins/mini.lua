return {
    'echasnovski/mini.indentscope',
    version = '*',
    config = function()
        require('mini.indentscope').setup({
            draw = {
                animation = require('mini.indentscope').gen_animation.exponential({
                    duration = 10,
                    unit = "total",
                }),
            },
        })
    end
}
