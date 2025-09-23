module docs

import cli
import v.vmod

pub fn create_cli() cli.Command {
	vm := vmod.decode(@VMOD_FILE) or { panic(err) }
	mut commands := cli.Command{
		name:        vm.name
		description: vm.description
		flags:       [
			cli.Flag{
				flag:        .bool
				name:        'help'
				abbrev:      'h'
				description: 'Show help message'
				global:      false // can change for chaining help flag
				required:    false
			},
		]
		commands:    [
			cli.Command{
				name:        'help'
				description: 'Show help message'
				execute:     fn (cmd cli.Command) ! {
					println(cmd.root().help_message())
					return
				}
			},
		]
	}
	return commands
}
