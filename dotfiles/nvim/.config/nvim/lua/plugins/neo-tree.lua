return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    filesystem = {
      window = {
        mappings = {
          ["<A-h>"] = "toggle_hidden",
          ["H"] = "none",
        },
      },
    },
  },
}
