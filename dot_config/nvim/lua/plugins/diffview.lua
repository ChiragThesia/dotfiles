return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewToggleFiles", "DiffviewFocusFiles" },
  keys = {
    { "<leader>gv", "<cmd>DiffviewOpen<cr>", desc = "Open Diffview (working tree)" },
    { "<leader>gV", "<cmd>DiffviewClose<cr>", desc = "Close Diffview" },
    { "<leader>gtf", "<cmd>DiffviewFileHistory %<cr>", desc = "File History (current file)" },
    { "<leader>gtb", "<cmd>DiffviewFileHistory<cr>", desc = "Branch History (all files)" },
  },
  opts = {
    view = {
      merge_tool = { layout = "diff1_plain" },
    },
  },
}
