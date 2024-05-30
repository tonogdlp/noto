local reload = function()
  package.loaded.Noto = nil
  require("noto").setup()
end
