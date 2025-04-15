return {
    'echasnovski/mini.indentscope',
    version = '*' ,
    config = function()
        require('mini.indentscope').setup()
        require('mini.indentscope').gen_animation.exponential()
    end
}
