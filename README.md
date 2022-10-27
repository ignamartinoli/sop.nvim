# [Beta] The SOP Neovim quickstart distribution

## Installation

To install, run either

```bash
wget -O - 'https://raw.githubusercontent.com/ignamartinoli/sop.nvim/master/install.sh' | sh
```

or

```bash
curl -fsSL 'https://raw.githubusercontent.com/ignamartinoli/sop.nvim/master/install.sh' | sh
```

## Dependencies

- [`curl`](https://curl.se) or [`wget`](https://www.gnu.org/software/wget)
- [`doas`](https://man.openbsd.org/doas) or [`sudo`](https://www.sudo.ws)
- [`git`](https://git-scm.com)
- [`npm`](https://www.npmjs.com)
- A supported package manager

## Mappings

### Normal mode

- `<C-d>` center screen
- `ga` code actions
- `gd` get diagnostics
- `gi` get implementations
- `gr` get references
- `K` documentation

## TODO

- [ ] Test on more distributions
- [ ] List supported distributions instead of package managers
