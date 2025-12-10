return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  config = function()
    require("catppuccin").setup({
      flavour = "frappe",
      transparent_background = true,
      integrations = {
        treesitter = true,
        telescope = true,
        gitsigns = true,
        cmp = true,
        notify = true,
        which_key = true,
      },
    })

    vim.cmd.colorscheme("catppuccin")
  end,
}
