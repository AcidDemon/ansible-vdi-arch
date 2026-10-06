vim.filetype.add({
  extension = {
    hujson = "hjson",
  },
  pattern = {
    [".*/apparmor%.d/.*"] = "apparmor",
    [".*/apparmor/profiles/.*"] = "apparmor",
    ["*.aa"] = "apparmor",
  },
})
