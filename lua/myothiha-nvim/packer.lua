-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- Telescope
  use {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    requires = { {'nvim-lua/plenary.nvim'} }
  }

  -- Treesitter
  use('nvim-treesitter/nvim-treesitter', { run = ':TSUpdate' })
  use 'nvim-treesitter/playground'
  use 'nvim-lua/plenary.nvim'

  -- Other plugins
  use 'ThePrimeagen/harpoon'
  use 'mbbill/undotree'
  use 'neovim/nvim-lspconfig'
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-cmdline'
  
  -- Vsnip and snippet integration
  use 'hrsh7th/vim-vsnip'
  use 'hrsh7th/cmp-vsnip'

  -- Auto-install plugins if Packer is not yet installed
  if packer_bootstrap then
    require('packer').sync()
  end
end)


  
