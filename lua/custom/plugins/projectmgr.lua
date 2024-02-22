return {
    'charludo/projectmgr.nvim',
    lazy = false,
    config = function ()
        vim.keymap.set('n', '<leader>sp', ":ProjectMgr<CR>", { desc = "[S]earch [P]rojects" })
    end,
}
