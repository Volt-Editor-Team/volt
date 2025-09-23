module docs

import cli
import v.vmod

pub fn create_cli() cli.Command {
	vm := vmod.decode(@VMOD_FILE) or { panic(err) }
	mut commands := cli.Command{
		name:        vm.name
		description: vm.description
		version:     vm.version
		flags:       [
			cli.Flag{
				flag:        .bool
				name:        'help'
				abbrev:      'h'
				description: 'Show help message'
				global:      false // can change for chaining help flag
				required:    false
			},
			cli.Flag{
				flag:        .bool
				name:        'version'
				abbrev:      'v'
				description: 'Show version'
				global:      false
				required:    false
			},
		]
		commands:    [
			cli.Command{
				name:        'help'
				description: 'Show help message'
				execute:     fn (cmd cli.Command) ! {
					println(cmd.root().help_message())
				}
			},
			cli.Command{
				name:        'version'
				description: 'Show version'
				execute:     fn (cmd cli.Command) ! {
					println(cmd.root().version())
				}
			},
		]
	}
	return commands
}
