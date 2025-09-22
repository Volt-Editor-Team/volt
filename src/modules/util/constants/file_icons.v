module constants

pub struct FileType {
pub:
	name        string
	color       string
	cterm_color string
	icon        string
}

pub const ext_icons = init_ext_icons()

// __global (
//   mut ext_icons map[string]FileType
// )

pub fn init_ext_icons() map[string]FileType {
	return {
		'.3gp':           FileType{
			icon:        ''
			color:       '#FD971F'
			cterm_color: '208'
			name:        '3gp'
		}
		'.3mf':           FileType{
			icon:        '󰆧'
			color:       '#888888'
			cterm_color: '102'
			name:        '3DObjectFile'
		}
		'.7z':            FileType{
			icon:        ''
			color:       '#ECA517'
			cterm_color: '214'
			name:        '7z'
		}
		'.Dockerfile':    FileType{
			icon:        '󰡨'
			color:       '#458EE6'
			cterm_color: '68'
			name:        'Dockerfile'
		}
		'.R':             FileType{
			icon:        '󰟔'
			color:       '#2266BA'
			cterm_color: '25'
			name:        'R'
		}
		'.a':             FileType{
			icon:        ''
			color:       '#DCDDD6'
			cterm_color: '253'
			name:        'StaticLibraryArchive'
		}
		'.aac':           FileType{
			icon:        ''
			color:       '#00AFFF'
			cterm_color: '39'
			name:        'AdvancedAudioCoding'
		}
		'.ada':           FileType{
			icon:        ''
			color:       '#599EFF'
			cterm_color: '111'
			name:        'AdaFile'
		}
		'.adb':           FileType{
			icon:        ''
			color:       '#599EFF'
			cterm_color: '111'
			name:        'AdaBody'
		}
		'.ads':           FileType{
			icon:        ''
			color:       '#A074C4'
			cterm_color: '140'
			name:        'AdaSpecification'
		}
		'.ai':            FileType{
			icon:        ''
			color:       '#CBCB41'
			cterm_color: '185'
			name:        'Ai'
		}
		'.aif':           FileType{
			icon:        ''
			color:       '#00AFFF'
			cterm_color: '39'
			name:        'AudioInterchangeFileFormat'
		}
		'.aiff':          FileType{
			icon:        ''
			color:       '#00AFFF'
			cterm_color: '39'
			name:        'AudioInterchangeFileFormat'
		}
		'.android':       FileType{
			icon:        ''
			color:       '#34A853'
			cterm_color: '35'
			name:        'Android'
		}
		'.ape':           FileType{
			icon:        ''
			color:       '#00AFFF'
			cterm_color: '39'
			name:        'MonkeysAudio'
		}
		'.apk':           FileType{
			icon:        ''
			color:       '#34A853'
			cterm_color: '35'
			name:        'apk'
		}
		'.apl':           FileType{
			icon:        ''
			color:       '#24A148'
			cterm_color: '35'
			name:        'APL'
		}
		'.app':           FileType{
			icon:        ''
			color:       '#9F0500'
			cterm_color: '124'
			name:        'App'
		}
		'.applescript':   FileType{
			icon:        ''
			color:       '#6D8085'
			cterm_color: '66'
			name:        'AppleScript'
		}
		'.asc':           FileType{
			icon:        '󰦝'
			color:       '#576D7F'
			cterm_color: '242'
			name:        'Asc'
		}
		'.asm':           FileType{
			icon:        ''
			color:       '#0091BD'
			cterm_color: '31'
			name:        'ASM'
		}
		'.ass':           FileType{
			icon:        '󰨖'
			color:       '#FFB713'
			cterm_color: '214'
			name:        'Ass'
		}
		'.astro':         FileType{
			icon:        ''
			color:       '#E23F67'
			cterm_color: '197'
			name:        'Astro'
		}
		'.avif':          FileType{
			icon:        ''
			color:       '#A074C4'
			cterm_color: '140'
			name:        'Avif'
		}
		'.awk':           FileType{
			icon:        ''
			color:       '#4D5A5E'
			cterm_color: '240'
			name:        'Awk'
		}
		'.azcli':         FileType{
			icon:        ''
			color:       '#0078D4'
			cterm_color: '32'
			name:        'AzureCli'
		}
		'.bak':           FileType{
			icon:        '󰁯'
			color:       '#6D8086'
			cterm_color: '66'
			name:        'Backup'
		}
		'.bash':          FileType{
			icon:        ''
			color:       '#89E051'
			cterm_color: '113'
			name:        'Bash'
		}
		'.bat':           FileType{
			icon:        ''
			color:       '#C1F12E'
			cterm_color: '191'
			name:        'Bat'
		}
		'.bazel':         FileType{
			icon:        ''
			color:       '#89E051'
			cterm_color: '113'
			name:        'Bazel'
		}
		'.bib':           FileType{
			icon:        '󱉟'
			color:       '#CBCB41'
			cterm_color: '185'
			name:        'BibTeX'
		}
		'.bicep':         FileType{
			icon:        ''
			color:       '#519ABA'
			cterm_color: '74'
			name:        'Bicep'
		}
		'.bicepparam':    FileType{
			icon:        ''
			color:       '#9F74B3'
			cterm_color: '133'
			name:        'BicepParameters'
		}
		'.bin':           FileType{
			icon:        ''
			color:       '#9F0500'
			cterm_color: '124'
			name:        'Bin'
		}
		'.badephp':       FileType{
			icon:        ''
			color:       '#F05340'
			cterm_color: '203'
			name:        'Blade'
		}
		'.blend':         FileType{
			icon:        '󰂫'
			color:       '#EA7600'
			cterm_color: '208'
			name:        'Blender'
		}
		'.blp':           FileType{
			icon:        '󰺾'
			color:       '#5796E2'
			cterm_color: '68'
			name:        'Blueprint'
		}
		'.bmp':           FileType{
			icon:        ''
			color:       '#A074C4'
			cterm_color: '140'
			name:        'Bmp'
		}
		'.bqn':           FileType{
			icon:        ''
			color:       '#24A148'
			cterm_color: '35'
			name:        'APL'
		}
		'.brep':          FileType{
			icon:        '󰻫'
			color:       '#839463'
			cterm_color: '101'
			name:        'BoundaryRepresentation'
		}
		'.bz':            FileType{
			icon:        ''
			color:       '#ECA517'
			cterm_color: '214'
			name:        'Bz'
		}
		'.bz2':           FileType{
			icon:        ''
			color:       '#ECA517'
			cterm_color: '214'
			name:        'Bz2'
		}
		'.bz3':           FileType{
			icon:        ''
			color:       '#ECA517'
			cterm_color: '214'
			name:        'Bz3'
		}
		'.bzl':           FileType{
			icon:        ''
			color:       '#89E051'
			cterm_color: '113'
			name:        'Bzl'
		}
		'.c':             FileType{
			icon:        ''
			color:       '#599EFF'
			cterm_color: '111'
			name:        'C'
		}
		'.c+':            FileType{
			icon:        ''
			color:       '#F34B7D'
			cterm_color: '204'
			name:        'CPlusPlus'
		}
		'.cache':         FileType{
			icon:        ''
			color:       '#FFFFFF'
			cterm_color: '231'
			name:        'Cache'
		}
		'.cast':          FileType{
			icon:        ''
			color:       '#FD971F'
			cterm_color: '208'
			name:        'Asciinema'
		}
		'.cbl':           FileType{
			icon:        ''
			color:       '#005CA5'
			cterm_color: '25'
			name:        'Cobol'
		}
		'.cc':            FileType{
			icon:        ''
			color:       '#F34B7D'
			cterm_color: '204'
			name:        'CPlusPlus'
		}
		'.ccm':           FileType{
			icon:        ''
			color:       '#F34B7D'
			cterm_color: '204'
			name:        'CPlusPlusModule'
		}
		'.cfc':           FileType{
			icon:        ''
			color:       '#01A4BA'
			cterm_color: '38'
			name:        'ColdFusionScript'
		}
		'.cfg':           FileType{
			icon:        ''
			color:       '#6D8086'
			cterm_color: '66'
			name:        'Configuration'
		}
		'.cfm':           FileType{
			icon:        ''
			color:       '#01A4BA'
			cterm_color: '38'
			name:        'ColdFusionTag'
		}
		'.cjs':           FileType{
			icon:        ''
			color:       '#CBCB41'
			cterm_color: '185'
			name:        'Cjs'
		}
		'.clj':           FileType{
			icon:        ''
			color:       '#8DC149'
			cterm_color: '113'
			name:        'Clojure'
		}
		'.cljc':          FileType{
			icon:        ''
			color:       '#8DC149'
			cterm_color: '113'
			name:        'ClojureC'
		}
		'.cljd':          FileType{
			icon:        ''
			color:       '#519ABA'
			cterm_color: '74'
			name:        'ClojureDart'
		}
		'.cljs':          FileType{
			icon:        ''
			color:       '#519ABA'
			cterm_color: '74'
			name:        'ClojureJS'
		}
		'.cmake':         FileType{
			icon:        ''
			color:       '#DCE3EB'
			cterm_color: '254'
			name:        'CMake'
		}
		'.cob':           FileType{
			icon:        ''
			color:       '#005CA5'
			cterm_color: '25'
			name:        'Cobol'
		}
		'.cobol':         FileType{
			icon:        ''
			color:       '#005CA5'
			cterm_color: '25'
			name:        'Cobol'
		}
		'.coffee':        FileType{
			icon:        ''
			color:       '#CBCB41'
			cterm_color: '185'
			name:        'Coffee'
		}
		'.conda':         FileType{
			icon:        ''
			color:       '#43B02A'
			cterm_color: '34'
			name:        'Conda'
		}
		'.conf':          FileType{
			icon:        ''
			color:       '#6D8086'
			cterm_color: '66'
			name:        'Conf'
		}
		'.cnfigru':       FileType{
			icon:        ''
			color:       '#701516'
			cterm_color: '52'
			name:        'ConfigRu'
		}
		'.cow':           FileType{
			icon:        '󰆚'
			color:       '#965824'
			cterm_color: '130'
			name:        'CowsayFile'
		}
		'.cp':            FileType{
			icon:        ''
			color:       '#519ABA'
			cterm_color: '74'
			name:        'Cp'
		}
		'.cpp':           FileType{
			icon:        ''
			color:       '#519ABA'
			cterm_color: '74'
			name:        'Cpp'
		}
		'.cppm':          FileType{
			icon:        ''
			color:       '#519ABA'
			cterm_color: '74'
			name:        'Cppm'
		}
		'.cpy':           FileType{
			icon:        ''
			color:       '#005CA5'
			cterm_color: '25'
			name:        'Cobol'
		}
		'.cr':            FileType{
			icon:        ''
			color:       '#C8C8C8'
			cterm_color: '251'
			name:        'Crystal'
		}
		'.crdownload':    FileType{
			icon:        ''
			color:       '#44CDA8'
			cterm_color: '43'
			name:        'Crdownload'
		}
		'.cs':            FileType{
			icon:        '󰌛'
			color:       '#596706'
			cterm_color: '58'
			name:        'Cs'
		}
		'.csh':           FileType{
			icon:        ''
			color:       '#4D5A5E'
			cterm_color: '240'
			name:        'Csh'
		}
		'.cshtml':        FileType{
			icon:        '󱦗'
			color:       '#512BD4'
			cterm_color: '56'
			name:        'RazorPage'
		}
		'.cson':          FileType{
			icon:        ''
			color:       '#CBCB41'
			cterm_color: '185'
			name:        'Cson'
		}
		'.csproj':        FileType{
			icon:        '󰪮'
			color:       '#512BD4'
			cterm_color: '56'
			name:        'CSharpProject'
		}
		'.css':           FileType{
			icon:        ''
			color:       '#663399'
			cterm_color: '91'
			name:        'Css'
		}
		'.csv':           FileType{
			icon:        ''
			color:       '#89E051'
			cterm_color: '113'
			name:        'Csv'
		}
		'.cts':           FileType{
			icon:        ''
			color:       '#519ABA'
			cterm_color: '74'
			name:        'Cts'
		}
		'.cu':            FileType{
			icon:        ''
			color:       '#89E051'
			cterm_color: '113'
			name:        'cuda'
		}
		'.cue':           FileType{
			icon:        '󰲹'
			color:       '#ED95AE'
			cterm_color: '211'
			name:        'Cue'
		}
		'.cuh':           FileType{
			icon:        ''
			color:       '#A074C4'
			cterm_color: '140'
			name:        'cudah'
		}
		'.cxx':           FileType{
			icon:        ''
			color:       '#519ABA'
			cterm_color: '74'
			name:        'Cxx'
		}
		'.cxxm':          FileType{
			icon:        ''
			color:       '#519ABA'
			cterm_color: '74'
			name:        'Cxxm'
		}
		'.d':             FileType{
			icon:        ''
			color:       '#B03931'
			cterm_color: '124'
			name:        'D'
		}
		'.d.t':           FileType{
			icon:        ''
			color:       '#D59855'
			cterm_color: '172'
			name:        'TypeScriptDeclaration'
		}
		'.dart':          FileType{
			icon:        ''
			color:       '#03589C'
			cterm_color: '25'
			name:        'Dart'
		}
		'.db':            FileType{
			icon:        ''
			color:       '#DAD8D8'
			cterm_color: '188'
			name:        'Db'
		}
		'.dconf':         FileType{
			icon:        ''
			color:       '#FFFFFF'
			cterm_color: '231'
			name:        'Dconf'
		}
		'.desktop':       FileType{
			icon:        ''
			color:       '#563D7C'
			cterm_color: '54'
			name:        'DesktopEntry'
		}
		'.diff':          FileType{
			icon:        ''
			color:       '#41535B'
			cterm_color: '239'
			name:        'Diff'
		}
		'.dll':           FileType{
			icon:        ''
			color:       '#4D2C0B'
			cterm_color: '52'
			name:        'Dll'
		}
		'.doc':           FileType{
			icon:        '󰈬'
			color:       '#185ABD'
			cterm_color: '26'
			name:        'Doc'
		}
		'.dockerignore':  FileType{
			icon:        '󰡨'
			color:       '#458EE6'
			cterm_color: '68'
			name:        'DockerIgnore'
		}
		'.docx':          FileType{
			icon:        '󰈬'
			color:       '#185ABD'
			cterm_color: '26'
			name:        'Docx'
		}
		'.dot':           FileType{
			icon:        '󱁉'
			color:       '#30638E'
			cterm_color: '24'
			name:        'Dot'
		}
		'.download':      FileType{
			icon:        ''
			color:       '#44CDA8'
			cterm_color: '43'
			name:        'Download'
		}
		'.drl':           FileType{
			icon:        ''
			color:       '#FFAFAF'
			cterm_color: '217'
			name:        'Drools'
		}
		'.dropbox':       FileType{
			icon:        ''
			color:       '#0061FE'
			cterm_color: '27'
			name:        'Dropbox'
		}
		'.dump':          FileType{
			icon:        ''
			color:       '#DAD8D8'
			cterm_color: '188'
			name:        'Dump'
		}
		'.dwg':           FileType{
			icon:        '󰻫'
			color:       '#839463'
			cterm_color: '101'
			name:        'AutoCADDwg'
		}
		'.dxf':           FileType{
			icon:        '󰻫'
			color:       '#839463'
			cterm_color: '101'
			name:        'AutoCADDxf'
		}
		'.ebook':         FileType{
			icon:        ''
			color:       '#EAB16D'
			cterm_color: '215'
			name:        'Ebook'
		}
		'.ebuild':        FileType{
			icon:        ''
			color:       '#4C416E'
			cterm_color: '60'
			name:        'GentooBuild'
		}
		'.edn':           FileType{
			icon:        ''
			color:       '#519ABA'
			cterm_color: '74'
			name:        'Edn'
		}
		'.eex':           FileType{
			icon:        ''
			color:       '#A074C4'
			cterm_color: '140'
			name:        'Eex'
		}
		'.ejs':           FileType{
			icon:        ''
			color:       '#CBCB41'
			cterm_color: '185'
			name:        'Ejs'
		}
		'.el':            FileType{
			icon:        ''
			color:       '#8172BE'
			cterm_color: '97'
			name:        'Elisp'
		}
		'.elc':           FileType{
			icon:        ''
			color:       '#8172BE'
			cterm_color: '97'
			name:        'Elisp'
		}
		'.elf':           FileType{
			icon:        ''
			color:       '#9F0500'
			cterm_color: '124'
			name:        'Elf'
		}
		'.elm':           FileType{
			icon:        ''
			color:       '#519ABA'
			cterm_color: '74'
			name:        'Elm'
		}
		'.eln':           FileType{
			icon:        ''
			color:       '#8172BE'
			cterm_color: '97'
			name:        'Elisp'
		}
		'.env':           FileType{
			icon:        ''
			color:       '#FAF743'
			cterm_color: '227'
			name:        'Env'
		}
		'.eot':           FileType{
			icon:        ''
			color:       '#ECECEC'
			cterm_color: '255'
			name:        'EmbeddedOpenTypeFont'
		}
		'.epp':           FileType{
			icon:        ''
			color:       '#FFA61A'
			cterm_color: '214'
			name:        'Epp'
		}
		'.epub':          FileType{
			icon:        ''
			color:       '#EAB16D'
			cterm_color: '215'
			name:        'Epub'
		}
		'.erb':           FileType{
			icon:        ''
			color:       '#701516'
			cterm_color: '52'
			name:        'Erb'
		}
		'.erl':           FileType{
			icon:        ''
			color:       '#B83998'
			cterm_color: '163'
			name:        'Erl'
		}
		'.ex':            FileType{
			icon:        ''
			color:       '#A074C4'
			cterm_color: '140'
			name:        'Ex'
		}
		'.exe':           FileType{
			icon:        ''
			color:       '#9F0500'
			cterm_color: '124'
			name:        'Exe'
		}
		'.exs':           FileType{
			icon:        ''
			color:       '#A074C4'
			cterm_color: '140'
			name:        'Exs'
		}
		'.f#':            FileType{
			icon:        ''
			color:       '#519ABA'
			cterm_color: '74'
			name:        'Fsharp'
		}
		'.f3d':           FileType{
			icon:        '󰻫'
			color:       '#839463'
			cterm_color: '101'
			name:        'Fusion360'
		}
		'.f90':           FileType{
			icon:        '󱈚'
			color:       '#734F96'
			cterm_color: '97'
			name:        'Fortran'
		}
		'.fbx':           FileType{
			icon:        '󰆧'
			color:       '#888888'
			cterm_color: '102'
			name:        '3DObjectFile'
		}
		'.fcbak':         FileType{
			icon:        ''
			color:       '#CB333B'
			cterm_color: '160'
			name:        'FreeCAD'
		}
		'.fcmacro':       FileType{
			icon:        ''
			color:       '#CB333B'
			cterm_color: '160'
			name:        'FreeCAD'
		}
		'.fcmat':         FileType{
			icon:        ''
			color:       '#CB333B'
			cterm_color: '160'
			name:        'FreeCAD'
		}
		'.fcparam':       FileType{
			icon:        ''
			color:       '#CB333B'
			cterm_color: '160'
			name:        'FreeCAD'
		}
		'.fcscript':      FileType{
			icon:        ''
			color:       '#CB333B'
			cterm_color: '160'
			name:        'FreeCAD'
		}
		'.fcstd':         FileType{
			icon:        ''
			color:       '#CB333B'
			cterm_color: '160'
			name:        'FreeCAD'
		}
		'.fcstd1':        FileType{
			icon:        ''
			color:       '#CB333B'
			cterm_color: '160'
			name:        'FreeCAD'
		}
		'.fctb':          FileType{
			icon:        ''
			color:       '#CB333B'
			cterm_color: '160'
			name:        'FreeCAD'
		}
		'.fctl':          FileType{
			icon:        ''
			color:       '#CB333B'
			cterm_color: '160'
			name:        'FreeCAD'
		}
		'.fdmdownload':   FileType{
			icon:        ''
			color:       '#44CDA8'
			cterm_color: '43'
			name:        'Fdmdownload'
		}
		'.feature':       FileType{
			icon:        ''
			color:       '#00A818'
			cterm_color: '34'
			name:        'Feature'
		}
		'.fish':          FileType{
			icon:        ''
			color:       '#4D5A5E'
			cterm_color: '240'
			name:        'Fish'
		}
		'.flac':          FileType{
			icon:        ''
			color:       '#0075AA'
			cterm_color: '24'
			name:        'FreeLosslessAudioCodec'
		}
		'.flc':           FileType{
			icon:        ''
			color:       '#ECECEC'
			cterm_color: '255'
			name:        'FIGletFontControl'
		}
		'.flf':           FileType{
			icon:        ''
			color:       '#ECECEC'
			cterm_color: '255'
			name:        'FIGletFontFormat'
		}
		'.fnl':           FileType{
			icon:        ''
			color:       '#FFF3D7'
			cterm_color: '230'
			name:        'Fennel'
		}
		'.fodg':          FileType{
			icon:        ''
			color:       '#FFFB57'
			cterm_color: '227'
			name:        'LibreOfficeGraphics'
		}
		'.fodp':          FileType{
			icon:        ''
			color:       '#FE9C45'
			cterm_color: '215'
			name:        'LibreOfficeImpress'
		}
		'.fods':          FileType{
			icon:        ''
			color:       '#78FC4E'
			cterm_color: '119'
			name:        'LibreOfficeCalc'
		}
		'.fodt':          FileType{
			icon:        ''
			color:       '#2DCBFD'
			cterm_color: '81'
			name:        'LibreOfficeWriter'
		}
		'.frag':          FileType{
			icon:        ''
			color:       '#5586A6'
			cterm_color: '67'
			name:        'FragmentShader'
		}
		'.fs':            FileType{
			icon:        ''
			color:       '#519ABA'
			cterm_color: '74'
			name:        'Fs'
		}
		'.fsi':           FileType{
			icon:        ''
			color:       '#519ABA'
			cterm_color: '74'
			name:        'Fsi'
		}
		'.fsscript':      FileType{
			icon:        ''
			color:       '#519ABA'
			cterm_color: '74'
			name:        'Fsscript'
		}
		'.fsx':           FileType{
			icon:        ''
			color:       '#519ABA'
			cterm_color: '74'
			name:        'Fsx'
		}
		'.gcode':         FileType{
			icon:        '󰐫'
			color:       '#1471AD'
			cterm_color: '32'
			name:        'GCode'
		}
		'.gd':            FileType{
			icon:        ''
			color:       '#6D8086'
			cterm_color: '66'
			name:        'GDScript'
		}
		'.gemspec':       FileType{
			icon:        ''
			color:       '#701516'
			cterm_color: '52'
			name:        'Gemspec'
		}
		'.geom':          FileType{
			icon:        ''
			color:       '#5586A6'
			cterm_color: '67'
			name:        'GeometryShader'
		}
		'.gif':           FileType{
			icon:        ''
			color:       '#A074C4'
			cterm_color: '140'
			name:        'Gif'
		}
		'.git':           FileType{
			icon:        ''
			color:       '#F14C28'
			cterm_color: '196'
			name:        'GitLogo'
		}
		'.glb':           FileType{
			icon:        ''
			color:       '#FFB13B'
			cterm_color: '214'
			name:        'BinaryGLTF'
		}
		'.gleam':         FileType{
			icon:        ''
			color:       '#FFAFF3'
			cterm_color: '219'
			name:        'Gleam'
		}
		'.glsl':          FileType{
			icon:        ''
			color:       '#5586A6'
			cterm_color: '67'
			name:        'OpenGLShadingLanguage'
		}
		'.gnumakefile':   FileType{
			icon:        ''
			color:       '#6D8086'
			cterm_color: '66'
			name:        'Makefile'
		}
		'.go':            FileType{
			icon:        ''
			color:       '#00ADD8'
			cterm_color: '38'
			name:        'Go'
		}
		'.godot':         FileType{
			icon:        ''
			color:       '#6D8086'
			cterm_color: '66'
			name:        'GodotProject'
		}
		'.gpr':           FileType{
			icon:        ''
			color:       '#6D8086'
			cterm_color: '66'
			name:        'GPRBuildProject'
		}
		'.gql':           FileType{
			icon:        ''
			color:       '#E535AB'
			cterm_color: '199'
			name:        'GraphQL'
		}
		'.gradle':        FileType{
			icon:        ''
			color:       '#005F87'
			cterm_color: '24'
			name:        'Gradle'
		}
		'.graphql':       FileType{
			icon:        ''
			color:       '#E535AB'
			cterm_color: '199'
			name:        'GraphQL'
		}
		'.gresource':     FileType{
			icon:        ''
			color:       '#FFFFFF'
			cterm_color: '231'
			name:        'GTK'
		}
		'.gv':            FileType{
			icon:        '󱁉'
			color:       '#30638E'
			cterm_color: '24'
			name:        'Gv'
		}
		'.gz':            FileType{
			icon:        ''
			color:       '#ECA517'
			cterm_color: '214'
			name:        'Gz'
		}
		'.h':             FileType{
			icon:        ''
			color:       '#A074C4'
			cterm_color: '140'
			name:        'H'
		}
		'.haml':          FileType{
			icon:        ''
			color:       '#EAEAE1'
			cterm_color: '255'
			name:        'Haml'
		}
		'.hbs':           FileType{
			icon:        ''
			color:       '#F0772B'
			cterm_color: '202'
			name:        'Hbs'
		}
		'.heex':          FileType{
			icon:        ''
			color:       '#A074C4'
			cterm_color: '140'
			name:        'Heex'
		}
		'.hex':           FileType{
			icon:        ''
			color:       '#2E63FF'
			cterm_color: '27'
			name:        'Hexadecimal'
		}
		'.hh':            FileType{
			icon:        ''
			color:       '#A074C4'
			cterm_color: '140'
			name:        'Hh'
		}
		'.hpp':           FileType{
			icon:        ''
			color:       '#A074C4'
			cterm_color: '140'
			name:        'Hpp'
		}
		'.hrl':           FileType{
			icon:        ''
			color:       '#B83998'
			cterm_color: '163'
			name:        'Hrl'
		}
		'.hs':            FileType{
			icon:        ''
			color:       '#A074C4'
			cterm_color: '140'
			name:        'Hs'
		}
		'.htm':           FileType{
			icon:        ''
			color:       '#E34C26'
			cterm_color: '196'
			name:        'Htm'
		}
		'.html':          FileType{
			icon:        ''
			color:       '#E44D26'
			cterm_color: '196'
			name:        'Html'
		}
		'.http':          FileType{
			icon:        ''
			color:       '#008EC7'
			cterm_color: '31'
			name:        'HTTP'
		}
		'.huff':          FileType{
			icon:        '󰡘'
			color:       '#4242C7'
			cterm_color: '56'
			name:        'Huff'
		}
		'.hurl':          FileType{
			icon:        ''
			color:       '#FF0288'
			cterm_color: '198'
			name:        'Hurl'
		}
		'.hx':            FileType{
			icon:        ''
			color:       '#EA8220'
			cterm_color: '208'
			name:        'Haxe'
		}
		'.hxx':           FileType{
			icon:        ''
			color:       '#A074C4'
			cterm_color: '140'
			name:        'Hxx'
		}
		'.ical':          FileType{
			icon:        ''
			color:       '#2B2E83'
			cterm_color: '18'
			name:        'Ical'
		}
		'.icalendar':     FileType{
			icon:        ''
			color:       '#2B2E83'
			cterm_color: '18'
			name:        'Icalendar'
		}
		'.ico':           FileType{
			icon:        ''
			color:       '#CBCB41'
			cterm_color: '185'
			name:        'Ico'
		}
		'.ics':           FileType{
			icon:        ''
			color:       '#2B2E83'
			cterm_color: '18'
			name:        'Ics'
		}
		'.ifb':           FileType{
			icon:        ''
			color:       '#2B2E83'
			cterm_color: '18'
			name:        'Ifb'
		}
		'.ifc':           FileType{
			icon:        '󰻫'
			color:       '#839463'
			cterm_color: '101'
			name:        'Ifc'
		}
		'.ige':           FileType{
			icon:        '󰻫'
			color:       '#839463'
			cterm_color: '101'
			name:        'Ige'
		}
		'.iges':          FileType{
			icon:        '󰻫'
			color:       '#839463'
			cterm_color: '101'
			name:        'Iges'
		}
		'.igs':           FileType{
			icon:        '󰻫'
			color:       '#839463'
			cterm_color: '101'
			name:        'Igs'
		}
		'.image':         FileType{
			icon:        ''
			color:       '#D0BEC8'
			cterm_color: '181'
			name:        'Image'
		}
		'.img':           FileType{
			icon:        ''
			color:       '#D0BEC8'
			cterm_color: '181'
			name:        'Img'
		}
		'.import':        FileType{
			icon:        ''
			color:       '#ECECEC'
			cterm_color: '255'
			name:        'ImportConfiguration'
		}
		'.info':          FileType{
			icon:        ''
			color:       '#FFFFCD'
			cterm_color: '230'
			name:        'Info'
		}
		'.ini':           FileType{
			icon:        ''
			color:       '#6D8086'
			cterm_color: '66'
			name:        'Ini'
		}
		'.ino':           FileType{
			icon:        ''
			color:       '#56B6C2'
			cterm_color: '73'
			name:        'Arduino'
		}
		'.ipynb':         FileType{
			icon:        ''
			color:       '#F57D01'
			cterm_color: '208'
			name:        'Notebook'
		}
		'.iso':           FileType{
			icon:        ''
			color:       '#D0BEC8'
			cterm_color: '181'
			name:        'Iso'
		}
		'.ixx':           FileType{
			icon:        ''
			color:       '#519ABA'
			cterm_color: '74'
			name:        'Ixx'
		}
		'.jar':           FileType{
			icon:        ''
			color:       '#ffaf67'
			cterm_color: '215'
			name:        'Jar'
		}
		'.java':          FileType{
			icon:        ''
			color:       '#CC3E44'
			cterm_color: '167'
			name:        'Java'
		}
		'.jl':            FileType{
			icon:        ''
			color:       '#A270BA'
			cterm_color: '133'
			name:        'Jl'
		}
		'.jpeg':          FileType{
			icon:        ''
			color:       '#A074C4'
			cterm_color: '140'
			name:        'Jpeg'
		}
		'.jpg':           FileType{
			icon:        ''
			color:       '#A074C4'
			cterm_color: '140'
			name:        'Jpg'
		}
		'.js':            FileType{
			icon:        ''
			color:       '#CBCB41'
			cterm_color: '185'
			name:        'Js'
		}
		'.json':          FileType{
			icon:        ''
			color:       '#CBCB41'
			cterm_color: '185'
			name:        'Json'
		}
		'.json5':         FileType{
			icon:        ''
			color:       '#CBCB41'
			cterm_color: '185'
			name:        'Json5'
		}
		'.jsonc':         FileType{
			icon:        ''
			color:       '#CBCB41'
			cterm_color: '185'
			name:        'Jsonc'
		}
		'.jsx':           FileType{
			icon:        ''
			color:       '#20C2E3'
			cterm_color: '45'
			name:        'Jsx'
		}
		'.jwmrc':         FileType{
			icon:        ''
			color:       '#0078CD'
			cterm_color: '32'
			name:        'JWM'
		}
		'.jxl':           FileType{
			icon:        ''
			color:       '#A074C4'
			cterm_color: '140'
			name:        'JpegXl'
		}
		'.kbx':           FileType{
			icon:        '󰯄'
			color:       '#737672'
			cterm_color: '243'
			name:        'Kbx'
		}
		'.kdb':           FileType{
			icon:        ''
			color:       '#529B34'
			cterm_color: '71'
			name:        'Kdb'
		}
		'.kdbx':          FileType{
			icon:        ''
			color:       '#529B34'
			cterm_color: '71'
			name:        'Kdbx'
		}
		'.kdenlive':      FileType{
			icon:        ''
			color:       '#83B8F2'
			cterm_color: '110'
			name:        'Kdenlive'
		}
		'.kdenlivetitle': FileType{
			icon:        ''
			color:       '#83B8F2'
			cterm_color: '110'
			name:        'Kdenlive'
		}
		'.kicad_dru':     FileType{
			icon:        ''
			color:       '#FFFFFF'
			cterm_color: '231'
			name:        'KiCad'
		}
		'.kicad_mod':     FileType{
			icon:        ''
			color:       '#FFFFFF'
			cterm_color: '231'
			name:        'KiCad'
		}
		'.kicad_pcb':     FileType{
			icon:        ''
			color:       '#FFFFFF'
			cterm_color: '231'
			name:        'KiCad'
		}
		'.kicad_prl':     FileType{
			icon:        ''
			color:       '#FFFFFF'
			cterm_color: '231'
			name:        'KiCad'
		}
		'.kicad_pro':     FileType{
			icon:        ''
			color:       '#FFFFFF'
			cterm_color: '231'
			name:        'KiCad'
		}
		'.kicad_sch':     FileType{
			icon:        ''
			color:       '#FFFFFF'
			cterm_color: '231'
			name:        'KiCad'
		}
		'.kicad_sym':     FileType{
			icon:        ''
			color:       '#FFFFFF'
			cterm_color: '231'
			name:        'KiCad'
		}
		'.kicad_wks':     FileType{
			icon:        ''
			color:       '#FFFFFF'
			cterm_color: '231'
			name:        'KiCad'
		}
		'.ko':            FileType{
			icon:        ''
			color:       '#DCDDD6'
			cterm_color: '253'
			name:        'LinuxKernelObject'
		}
		'.kpp':           FileType{
			icon:        ''
			color:       '#F245FB'
			cterm_color: '201'
			name:        'Krita'
		}
		'.kra':           FileType{
			icon:        ''
			color:       '#F245FB'
			cterm_color: '201'
			name:        'Krita'
		}
		'.krz':           FileType{
			icon:        ''
			color:       '#F245FB'
			cterm_color: '201'
			name:        'Krita'
		}
		'.ksh':           FileType{
			icon:        ''
			color:       '#4D5A5E'
			cterm_color: '240'
			name:        'Ksh'
		}
		'.kt':            FileType{
			icon:        ''
			color:       '#7F52FF'
			cterm_color: '99'
			name:        'Kotlin'
		}
		'.kts':           FileType{
			icon:        ''
			color:       '#7F52FF'
			cterm_color: '99'
			name:        'KotlinScript'
		}
		'.lck':           FileType{
			icon:        ''
			color:       '#BBBBBB'
			cterm_color: '250'
			name:        'Lock'
		}
		'.leex':          FileType{
			icon:        ''
			color:       '#A074C4'
			cterm_color: '140'
			name:        'Leex'
		}
		'.less':          FileType{
			icon:        ''
			color:       '#563D7C'
			cterm_color: '54'
			name:        'Less'
		}
		'.lff':           FileType{
			icon:        ''
			color:       '#ECECEC'
			cterm_color: '255'
			name:        'LibrecadFontFile'
		}
		'.lhs':           FileType{
			icon:        ''
			color:       '#A074C4'
			cterm_color: '140'
			name:        'Lhs'
		}
		'.lib':           FileType{
			icon:        ''
			color:       '#4D2C0B'
			cterm_color: '52'
			name:        'Lib'
		}
		'.license':       FileType{
			icon:        ''
			color:       '#CBCB41'
			cterm_color: '185'
			name:        'License'
		}
		'.liquid':        FileType{
			icon:        ''
			color:       '#95BF47'
			cterm_color: '106'
			name:        'Liquid'
		}
		'.lock':          FileType{
			icon:        ''
			color:       '#BBBBBB'
			cterm_color: '250'
			name:        'Lock'
		}
		'.log':           FileType{
			icon:        '󰌱'
			color:       '#DDDDDD'
			cterm_color: '253'
			name:        'Log'
		}
		'.lrc':           FileType{
			icon:        '󰨖'
			color:       '#FFB713'
			cterm_color: '214'
			name:        'Lrc'
		}
		'.lua':           FileType{
			icon:        ''
			color:       '#51A0CF'
			cterm_color: '74'
			name:        'Lua'
		}
		'.luac':          FileType{
			icon:        ''
			color:       '#51A0CF'
			cterm_color: '74'
			name:        'Lua'
		}
		'.luau':          FileType{
			icon:        ''
			color:       '#00A2FF'
			cterm_color: '75'
			name:        'Luau'
		}
		'.m':             FileType{
			icon:        ''
			color:       '#599EFF'
			cterm_color: '111'
			name:        'ObjectiveC'
		}
		'.m3u':           FileType{
			icon:        '󰲹'
			color:       '#ED95AE'
			cterm_color: '211'
			name:        'M3u'
		}
		'.m3u8':          FileType{
			icon:        '󰲹'
			color:       '#ED95AE'
			cterm_color: '211'
			name:        'M3u8'
		}
		'.m4a':           FileType{
			icon:        ''
			color:       '#00AFFF'
			cterm_color: '39'
			name:        'MPEG4'
		}
		'.m4v':           FileType{
			icon:        ''
			color:       '#FD971F'
			cterm_color: '208'
			name:        'M4V'
		}
		'.magnet':        FileType{
			icon:        ''
			color:       '#A51B16'
			cterm_color: '124'
			name:        'Magnet'
		}
		'.makefile':      FileType{
			icon:        ''
			color:       '#6D8086'
			cterm_color: '66'
			name:        'Makefile'
		}
		'.markdown':      FileType{
			icon:        ''
			color:       '#DDDDDD'
			cterm_color: '253'
			name:        'Markdown'
		}
		'.material':      FileType{
			icon:        ''
			color:       '#B83998'
			cterm_color: '163'
			name:        'Material'
		}
		'.md':            FileType{
			icon:        ''
			color:       '#DDDDDD'
			cterm_color: '253'
			name:        'Md'
		}
		'.md5':           FileType{
			icon:        '󰕥'
			color:       '#8C86AF'
			cterm_color: '103'
			name:        'Md5'
		}
		'.mdx':           FileType{
			icon:        ''
			color:       '#519ABA'
			cterm_color: '74'
			name:        'Mdx'
		}
		'.mint':          FileType{
			icon:        '󰌪'
			color:       '#87C095'
			cterm_color: '108'
			name:        'Mint'
		}
		'.mjs':           FileType{
			icon:        ''
			color:       '#F1E05A'
			cterm_color: '185'
			name:        'Mjs'
		}
		'.mk':            FileType{
			icon:        ''
			color:       '#6D8086'
			cterm_color: '66'
			name:        'Makefile'
		}
		'.mkv':           FileType{
			icon:        ''
			color:       '#FD971F'
			cterm_color: '208'
			name:        'Mkv'
		}
		'.ml':            FileType{
			icon:        ''
			color:       '#E37933'
			cterm_color: '166'
			name:        'Ml'
		}
		'.mli':           FileType{
			icon:        ''
			color:       '#E37933'
			cterm_color: '166'
			name:        'Mli'
		}
		'.mm':            FileType{
			icon:        ''
			color:       '#519ABA'
			cterm_color: '74'
			name:        'ObjectiveCPlusPlus'
		}
		'.mo':            FileType{
			icon:        ''
			color:       '#9772FB'
			cterm_color: '135'
			name:        'Motoko'
		}
		'.mobi':          FileType{
			icon:        ''
			color:       '#EAB16D'
			cterm_color: '215'
			name:        'Mobi'
		}
		'.mojo':          FileType{
			icon:        ''
			color:       '#FF4C1F'
			cterm_color: '196'
			name:        'Mojo'
		}
		'.mov':           FileType{
			icon:        ''
			color:       '#FD971F'
			cterm_color: '208'
			name:        'MOV'
		}
		'.mp3':           FileType{
			icon:        ''
			color:       '#00AFFF'
			cterm_color: '39'
			name:        'MPEGAudioLayerIII'
		}
		'.mp4':           FileType{
			icon:        ''
			color:       '#FD971F'
			cterm_color: '208'
			name:        'Mp4'
		}
		'.mpp':           FileType{
			icon:        ''
			color:       '#519ABA'
			cterm_color: '74'
			name:        'Mpp'
		}
		'.msf':           FileType{
			icon:        ''
			color:       '#137BE1'
			cterm_color: '33'
			name:        'Thunderbird'
		}
		'.mts':           FileType{
			icon:        ''
			color:       '#519ABA'
			cterm_color: '74'
			name:        'Mts'
		}
		'.mustache':      FileType{
			icon:        ''
			color:       '#E37933'
			cterm_color: '166'
			name:        'Mustache'
		}
		'.nfo':           FileType{
			icon:        ''
			color:       '#FFFFCD'
			cterm_color: '230'
			name:        'Nfo'
		}
		'.nim':           FileType{
			icon:        ''
			color:       '#F3D400'
			cterm_color: '220'
			name:        'Nim'
		}
		'.nix':           FileType{
			icon:        ''
			color:       '#7EBAE4'
			cterm_color: '110'
			name:        'Nix'
		}
		'.norg':          FileType{
			icon:        ''
			color:       '#4878BE'
			cterm_color: '32'
			name:        'Norg'
		}
		'.nswag':         FileType{
			icon:        ''
			color:       '#85EA2D'
			cterm_color: '112'
			name:        'Nswag'
		}
		'.nu':            FileType{
			icon:        ''
			color:       '#3AA675'
			cterm_color: '36'
			name:        'Nushell'
		}
		'.o':             FileType{
			icon:        ''
			color:       '#9F0500'
			cterm_color: '124'
			name:        'ObjectFile'
		}
		'.obj':           FileType{
			icon:        '󰆧'
			color:       '#888888'
			cterm_color: '102'
			name:        '3DObjectFile'
		}
		'.odf':           FileType{
			icon:        ''
			color:       '#FF5A96'
			cterm_color: '204'
			name:        'LibreOfficeFormula'
		}
		'.odg':           FileType{
			icon:        ''
			color:       '#FFFB57'
			cterm_color: '227'
			name:        'LibreOfficeGraphics'
		}
		'.odin':          FileType{
			icon:        '󰟢'
			color:       '#3882D2'
			cterm_color: '32'
			name:        'Odin'
		}
		'.odp':           FileType{
			icon:        ''
			color:       '#FE9C45'
			cterm_color: '215'
			name:        'LibreOfficeImpress'
		}
		'.ods':           FileType{
			icon:        ''
			color:       '#78FC4E'
			cterm_color: '119'
			name:        'LibreOfficeCalc'
		}
		'.odt':           FileType{
			icon:        ''
			color:       '#2DCBFD'
			cterm_color: '81'
			name:        'LibreOfficeWriter'
		}
		'.oga':           FileType{
			icon:        ''
			color:       '#0075AA'
			cterm_color: '24'
			name:        'OggVorbis'
		}
		'.ogg':           FileType{
			icon:        ''
			color:       '#0075AA'
			cterm_color: '24'
			name:        'OggVorbis'
		}
		'.ogv':           FileType{
			icon:        ''
			color:       '#FD971F'
			cterm_color: '208'
			name:        'OggVideo'
		}
		'.ogx':           FileType{
			icon:        ''
			color:       '#FD971F'
			cterm_color: '208'
			name:        'OggMultiplex'
		}
		'.opus':          FileType{
			icon:        ''
			color:       '#0075AA'
			cterm_color: '24'
			name:        'OpusAudioFile'
		}
		'.org':           FileType{
			icon:        ''
			color:       '#77AA99'
			cterm_color: '73'
			name:        'OrgMode'
		}
		'.otf':           FileType{
			icon:        ''
			color:       '#ECECEC'
			cterm_color: '255'
			name:        'OpenTypeFont'
		}
		'.out':           FileType{
			icon:        ''
			color:       '#9F0500'
			cterm_color: '124'
			name:        'Out'
		}
		'.part':          FileType{
			icon:        ''
			color:       '#44CDA8'
			cterm_color: '43'
			name:        'Part'
		}
		'.patch':         FileType{
			icon:        ''
			color:       '#41535B'
			cterm_color: '239'
			name:        'Patch'
		}
		'.pck':           FileType{
			icon:        ''
			color:       '#6D8086'
			cterm_color: '66'
			name:        'PackedResource'
		}
		'.pcm':           FileType{
			icon:        ''
			color:       '#0075AA'
			cterm_color: '24'
			name:        'PulseCodeModulation'
		}
		'.pdf':           FileType{
			icon:        ''
			color:       '#B30B00'
			cterm_color: '124'
			name:        'Pdf'
		}
		'.php':           FileType{
			icon:        ''
			color:       '#A074C4'
			cterm_color: '140'
			name:        'Php'
		}
		'.pl':            FileType{
			icon:        ''
			color:       '#519ABA'
			cterm_color: '74'
			name:        'Pl'
		}
		'.pls':           FileType{
			icon:        '󰲹'
			color:       '#ED95AE'
			cterm_color: '211'
			name:        'Pls'
		}
		'.ply':           FileType{
			icon:        '󰆧'
			color:       '#888888'
			cterm_color: '102'
			name:        '3DObjectFile'
		}
		'.pm':            FileType{
			icon:        ''
			color:       '#519ABA'
			cterm_color: '74'
			name:        'Pm'
		}
		'.png':           FileType{
			icon:        ''
			color:       '#A074C4'
			cterm_color: '140'
			name:        'Png'
		}
		'.po':            FileType{
			icon:        ''
			color:       '#2596BE'
			cterm_color: '31'
			name:        'Localization'
		}
		'.pot':           FileType{
			icon:        ''
			color:       '#2596BE'
			cterm_color: '31'
			name:        'Localization'
		}
		'.pp':            FileType{
			icon:        ''
			color:       '#FFA61A'
			cterm_color: '214'
			name:        'Pp'
		}
		'.ppt':           FileType{
			icon:        '󰈧'
			color:       '#CB4A32'
			cterm_color: '160'
			name:        'Ppt'
		}
		'.pptx':          FileType{
			icon:        '󰈧'
			color:       '#CB4A32'
			cterm_color: '160'
			name:        'Pptx'
		}
		'.prisma':        FileType{
			icon:        ''
			color:       '#5A67D8'
			cterm_color: '62'
			name:        'Prisma'
		}
		'.pro':           FileType{
			icon:        ''
			color:       '#E4B854'
			cterm_color: '179'
			name:        'Prolog'
		}
		'.ps1':           FileType{
			icon:        '󰨊'
			color:       '#4273CA'
			cterm_color: '68'
			name:        'PsScriptfile'
		}
		'.psb':           FileType{
			icon:        ''
			color:       '#519ABA'
			cterm_color: '74'
			name:        'Psb'
		}
		'.psd':           FileType{
			icon:        ''
			color:       '#519ABA'
			cterm_color: '74'
			name:        'Psd'
		}
		'.psd1':          FileType{
			icon:        '󰨊'
			color:       '#6975C4'
			cterm_color: '68'
			name:        'PsManifestfile'
		}
		'.psm1':          FileType{
			icon:        '󰨊'
			color:       '#6975C4'
			cterm_color: '68'
			name:        'PsScriptModulefile'
		}
		'.pub':           FileType{
			icon:        '󰷖'
			color:       '#E3C58E'
			cterm_color: '222'
			name:        'Pub'
		}
		'.pxd':           FileType{
			icon:        ''
			color:       '#5AA7E4'
			cterm_color: '39'
			name:        'Pxd'
		}
		'.pxi':           FileType{
			icon:        ''
			color:       '#5AA7E4'
			cterm_color: '39'
			name:        'Pxi'
		}
		'.py':            FileType{
			icon:        ''
			color:       '#FFBC03'
			cterm_color: '214'
			name:        'Py'
		}
		'.pyc':           FileType{
			icon:        ''
			color:       '#FFE291'
			cterm_color: '222'
			name:        'Pyc'
		}
		'.pyd':           FileType{
			icon:        ''
			color:       '#FFE291'
			cterm_color: '222'
			name:        'Pyd'
		}
		'.pyi':           FileType{
			icon:        ''
			color:       '#FFBC03'
			cterm_color: '214'
			name:        'Pyi'
		}
		'.pyo':           FileType{
			icon:        ''
			color:       '#FFE291'
			cterm_color: '222'
			name:        'Pyo'
		}
		'.pyw':           FileType{
			icon:        ''
			color:       '#5AA7E4'
			cterm_color: '39'
			name:        'Pyw'
		}
		'.pyx':           FileType{
			icon:        ''
			color:       '#5AA7E4'
			cterm_color: '39'
			name:        'Pyx'
		}
		'.qm':            FileType{
			icon:        ''
			color:       '#2596BE'
			cterm_color: '31'
			name:        'Localization'
		}
		'.qml':           FileType{
			icon:        ''
			color:       '#40CD52'
			cterm_color: '77'
			name:        'Qt'
		}
		'.qrc':           FileType{
			icon:        ''
			color:       '#40CD52'
			cterm_color: '77'
			name:        'Qt'
		}
		'.qss':           FileType{
			icon:        ''
			color:       '#40CD52'
			cterm_color: '77'
			name:        'Qt'
		}
		'.query':         FileType{
			icon:        ''
			color:       '#90A850'
			cterm_color: '107'
			name:        'Query'
		}
		'.r':             FileType{
			icon:        '󰟔'
			color:       '#2266BA'
			cterm_color: '25'
			name:        'R'
		}
		'.rake':          FileType{
			icon:        ''
			color:       '#701516'
			cterm_color: '52'
			name:        'Rake'
		}
		'.rar':           FileType{
			icon:        ''
			color:       '#ECA517'
			cterm_color: '214'
			name:        'Rar'
		}
		'.rasi':          FileType{
			icon:        ''
			color:       '#CBCB41'
			cterm_color: '185'
			name:        'Rasi'
		}
		'.razor':         FileType{
			icon:        '󱦘'
			color:       '#512BD4'
			cterm_color: '56'
			name:        'RazorPage'
		}
		'.rb':            FileType{
			icon:        ''
			color:       '#701516'
			cterm_color: '52'
			name:        'Rb'
		}
		'.res':           FileType{
			icon:        ''
			color:       '#CC3E44'
			cterm_color: '167'
			name:        'ReScript'
		}
		'.resi':          FileType{
			icon:        ''
			color:       '#F55385'
			cterm_color: '204'
			name:        'ReScriptInterface'
		}
		'.rlib':          FileType{
			icon:        ''
			color:       '#DEA584'
			cterm_color: '216'
			name:        'Rlib'
		}
		'.rmd':           FileType{
			icon:        ''
			color:       '#519ABA'
			cterm_color: '74'
			name:        'Rmd'
		}
		'.rproj':         FileType{
			icon:        '󰗆'
			color:       '#358A5B'
			cterm_color: '29'
			name:        'Rproj'
		}
		'.rs':            FileType{
			icon:        ''
			color:       '#DEA584'
			cterm_color: '216'
			name:        'Rs'
		}
		'.rss':           FileType{
			icon:        ''
			color:       '#FB9D3B'
			cterm_color: '215'
			name:        'Rss'
		}
		'.s':             FileType{
			icon:        ''
			color:       '#0071C5'
			cterm_color: '25'
			name:        'ASM'
		}
		'.sass':          FileType{
			icon:        ''
			color:       '#F55385'
			cterm_color: '204'
			name:        'Sass'
		}
		'.sbt':           FileType{
			icon:        ''
			color:       '#CC3E44'
			cterm_color: '167'
			name:        'sbt'
		}
		'.sc':            FileType{
			icon:        ''
			color:       '#CC3E44'
			cterm_color: '167'
			name:        'ScalaScript'
		}
		'.scad':          FileType{
			icon:        ''
			color:       '#F9D72C'
			cterm_color: '220'
			name:        'OpenSCAD'
		}
		'.scala':         FileType{
			icon:        ''
			color:       '#CC3E44'
			cterm_color: '167'
			name:        'Scala'
		}
		'.scm':           FileType{
			icon:        '󰘧'
			color:       '#EEEEEE'
			cterm_color: '255'
			name:        'Scheme'
		}
		'.scss':          FileType{
			icon:        ''
			color:       '#F55385'
			cterm_color: '204'
			name:        'Scss'
		}
		'.sh':            FileType{
			icon:        ''
			color:       '#4D5A5E'
			cterm_color: '240'
			name:        'Sh'
		}
		'.sha1':          FileType{
			icon:        '󰕥'
			color:       '#8C86AF'
			cterm_color: '103'
			name:        'Sha1'
		}
		'.sha224':        FileType{
			icon:        '󰕥'
			color:       '#8C86AF'
			cterm_color: '103'
			name:        'Sha224'
		}
		'.sha256':        FileType{
			icon:        '󰕥'
			color:       '#8C86AF'
			cterm_color: '103'
			name:        'Sha256'
		}
		'.sha384':        FileType{
			icon:        '󰕥'
			color:       '#8C86AF'
			cterm_color: '103'
			name:        'Sha384'
		}
		'.sha512':        FileType{
			icon:        '󰕥'
			color:       '#8C86AF'
			cterm_color: '103'
			name:        'Sha512'
		}
		'.sig':           FileType{
			icon:        '󰘧'
			color:       '#E37933'
			cterm_color: '166'
			name:        'Sig'
		}
		'.signature':     FileType{
			icon:        '󰘧'
			color:       '#E37933'
			cterm_color: '166'
			name:        'Signature'
		}
		'.skp':           FileType{
			icon:        '󰻫'
			color:       '#839463'
			cterm_color: '101'
			name:        'SketchUp'
		}
		'.sldasm':        FileType{
			icon:        '󰻫'
			color:       '#839463'
			cterm_color: '101'
			name:        'SolidWorksAsm'
		}
		'.sldprt':        FileType{
			icon:        '󰻫'
			color:       '#839463'
			cterm_color: '101'
			name:        'SolidWorksPrt'
		}
		'.slim':          FileType{
			icon:        ''
			color:       '#E34C26'
			cterm_color: '196'
			name:        'Slim'
		}
		'.sln':           FileType{
			icon:        ''
			color:       '#854CC7'
			cterm_color: '98'
			name:        'Sln'
		}
		'.slnx':          FileType{
			icon:        ''
			color:       '#854CC7'
			cterm_color: '98'
			name:        'Slnx'
		}
		'.slvs':          FileType{
			icon:        '󰻫'
			color:       '#839463'
			cterm_color: '101'
			name:        'SolveSpace'
		}
		'.sml':           FileType{
			icon:        '󰘧'
			color:       '#E37933'
			cterm_color: '166'
			name:        'Sml'
		}
		'.so':            FileType{
			icon:        ''
			color:       '#DCDDD6'
			cterm_color: '253'
			name:        'SharedObject'
		}
		'.sol':           FileType{
			icon:        ''
			color:       '#519ABA'
			cterm_color: '74'
			name:        'Solidity'
		}
		'.secjs':         FileType{
			icon:        ''
			color:       '#CBCB41'
			cterm_color: '185'
			name:        'SpecJs'
		}
		'.secjsx':        FileType{
			icon:        ''
			color:       '#20C2E3'
			cterm_color: '45'
			name:        'JavaScriptReactSpec'
		}
		'.sects':         FileType{
			icon:        ''
			color:       '#519ABA'
			cterm_color: '74'
			name:        'SpecTs'
		}
		'.sectsx':        FileType{
			icon:        ''
			color:       '#1354BF'
			cterm_color: '26'
			name:        'TypeScriptReactSpec'
		}
		'.spx':           FileType{
			icon:        ''
			color:       '#0075AA'
			cterm_color: '24'
			name:        'OggSpeexAudio'
		}
		'.sql':           FileType{
			icon:        ''
			color:       '#DAD8D8'
			cterm_color: '188'
			name:        'Sql'
		}
		'.sqlite':        FileType{
			icon:        ''
			color:       '#DAD8D8'
			cterm_color: '188'
			name:        'Sql'
		}
		'.sqlite3':       FileType{
			icon:        ''
			color:       '#DAD8D8'
			cterm_color: '188'
			name:        'Sql'
		}
		'.srt':           FileType{
			icon:        '󰨖'
			color:       '#FFB713'
			cterm_color: '214'
			name:        'Srt'
		}
		'.ssa':           FileType{
			icon:        '󰨖'
			color:       '#FFB713'
			cterm_color: '214'
			name:        'Ssa'
		}
		'.ste':           FileType{
			icon:        '󰻫'
			color:       '#839463'
			cterm_color: '101'
			name:        'Ste'
		}
		'.step':          FileType{
			icon:        '󰻫'
			color:       '#839463'
			cterm_color: '101'
			name:        'Step'
		}
		'.stl':           FileType{
			icon:        '󰆧'
			color:       '#888888'
			cterm_color: '102'
			name:        '3DObjectFile'
		}
		'.soriesjs':      FileType{
			icon:        ''
			color:       '#FF4785'
			cterm_color: '204'
			name:        'StorybookJavaScript'
		}
		'.soriesjsx':     FileType{
			icon:        ''
			color:       '#FF4785'
			cterm_color: '204'
			name:        'StorybookJsx'
		}
		'.soriesmjs':     FileType{
			icon:        ''
			color:       '#FF4785'
			cterm_color: '204'
			name:        'StorybookMjs'
		}
		'.soriessvelte':  FileType{
			icon:        ''
			color:       '#FF4785'
			cterm_color: '204'
			name:        'StorybookSvelte'
		}
		'.soriests':      FileType{
			icon:        ''
			color:       '#FF4785'
			cterm_color: '204'
			name:        'StorybookTypeScript'
		}
		'.soriestsx':     FileType{
			icon:        ''
			color:       '#FF4785'
			cterm_color: '204'
			name:        'StorybookTsx'
		}
		'.soriesvue':     FileType{
			icon:        ''
			color:       '#FF4785'
			cterm_color: '204'
			name:        'StorybookVue'
		}
		'.stp':           FileType{
			icon:        '󰻫'
			color:       '#839463'
			cterm_color: '101'
			name:        'Stp'
		}
		'.strings':       FileType{
			icon:        ''
			color:       '#2596BE'
			cterm_color: '31'
			name:        'Localization'
		}
		'.styl':          FileType{
			icon:        ''
			color:       '#8DC149'
			cterm_color: '113'
			name:        'Styl'
		}
		'.sub':           FileType{
			icon:        '󰨖'
			color:       '#FFB713'
			cterm_color: '214'
			name:        'Sub'
		}
		'.sublime':       FileType{
			icon:        ''
			color:       '#E37933'
			cterm_color: '166'
			name:        'Sublime'
		}
		'.suo':           FileType{
			icon:        ''
			color:       '#854CC7'
			cterm_color: '98'
			name:        'Suo'
		}
		'.sv':            FileType{
			icon:        '󰍛'
			color:       '#019833'
			cterm_color: '28'
			name:        'SystemVerilog'
		}
		'.svelte':        FileType{
			icon:        ''
			color:       '#FF3E00'
			cterm_color: '196'
			name:        'Svelte'
		}
		'.svg':           FileType{
			icon:        '󰜡'
			color:       '#FFB13B'
			cterm_color: '214'
			name:        'Svg'
		}
		'.svgz':          FileType{
			icon:        '󰜡'
			color:       '#FFB13B'
			cterm_color: '214'
			name:        'Svgz'
		}
		'.svh':           FileType{
			icon:        '󰍛'
			color:       '#019833'
			cterm_color: '28'
			name:        'SystemVerilog'
		}
		'.swift':         FileType{
			icon:        ''
			color:       '#E37933'
			cterm_color: '166'
			name:        'Swift'
		}
		'.t':             FileType{
			icon:        ''
			color:       '#519ABA'
			cterm_color: '74'
			name:        'Tor'
		}
		'.tbc':           FileType{
			icon:        '󰛓'
			color:       '#1E5CB3'
			cterm_color: '25'
			name:        'Tcl'
		}
		'.tcl':           FileType{
			icon:        '󰛓'
			color:       '#1E5CB3'
			cterm_color: '25'
			name:        'Tcl'
		}
		'.templ':         FileType{
			icon:        ''
			color:       '#DBBD30'
			cterm_color: '178'
			name:        'Templ'
		}
		'.terminal':      FileType{
			icon:        ''
			color:       '#31B53E'
			cterm_color: '34'
			name:        'Terminal'
		}
		'.tstjs':         FileType{
			icon:        ''
			color:       '#CBCB41'
			cterm_color: '185'
			name:        'TestJs'
		}
		'.tstjsx':        FileType{
			icon:        ''
			color:       '#20C2E3'
			cterm_color: '45'
			name:        'JavaScriptReactTest'
		}
		'.tstts':         FileType{
			icon:        ''
			color:       '#519ABA'
			cterm_color: '74'
			name:        'TestTs'
		}
		'.tsttsx':        FileType{
			icon:        ''
			color:       '#1354BF'
			cterm_color: '26'
			name:        'TypeScriptReactTest'
		}
		'.tex':           FileType{
			icon:        ''
			color:       '#3D6117'
			cterm_color: '22'
			name:        'Tex'
		}
		'.tf':            FileType{
			icon:        ''
			color:       '#5F43E9'
			cterm_color: '93'
			name:        'Terraform'
		}
		'.tfvars':        FileType{
			icon:        ''
			color:       '#5F43E9'
			cterm_color: '93'
			name:        'TFVars'
		}
		'.tgz':           FileType{
			icon:        ''
			color:       '#ECA517'
			cterm_color: '214'
			name:        'Tgz'
		}
		'.tmpl':          FileType{
			icon:        ''
			color:       '#DBBD30'
			cterm_color: '178'
			name:        'Template'
		}
		'.tmux':          FileType{
			icon:        ''
			color:       '#14BA19'
			cterm_color: '34'
			name:        'Tmux'
		}
		'.toml':          FileType{
			icon:        ''
			color:       '#9C4221'
			cterm_color: '124'
			name:        'Toml'
		}
		'.torrent':       FileType{
			icon:        ''
			color:       '#44CDA8'
			cterm_color: '43'
			name:        'Torrent'
		}
		'.tres':          FileType{
			icon:        ''
			color:       '#6D8086'
			cterm_color: '66'
			name:        'GodotTextResource'
		}
		'.ts':            FileType{
			icon:        ''
			color:       '#519ABA'
			cterm_color: '74'
			name:        'TypeScript'
		}
		'.tscn':          FileType{
			icon:        ''
			color:       '#6D8086'
			cterm_color: '66'
			name:        'GodotTextScene'
		}
		'.tsconfig':      FileType{
			icon:        ''
			color:       '#FF8700'
			cterm_color: '208'
			name:        'TypoScriptConfig'
		}
		'.tsx':           FileType{
			icon:        ''
			color:       '#1354BF'
			cterm_color: '26'
			name:        'Tsx'
		}
		'.ttf':           FileType{
			icon:        ''
			color:       '#ECECEC'
			cterm_color: '255'
			name:        'TrueTypeFont'
		}
		'.twig':          FileType{
			icon:        ''
			color:       '#8DC149'
			cterm_color: '113'
			name:        'Twig'
		}
		'.txt':           FileType{
			icon:        '󰈙'
			color:       '#89E051'
			cterm_color: '113'
			name:        'Txt'
		}
		'.txz':           FileType{
			icon:        ''
			color:       '#ECA517'
			cterm_color: '214'
			name:        'Txz'
		}
		'.typ':           FileType{
			icon:        ''
			color:       '#0DBCC0'
			cterm_color: '37'
			name:        'Typst'
		}
		'.typoscript':    FileType{
			icon:        ''
			color:       '#FF8700'
			cterm_color: '208'
			name:        'TypoScript'
		}
		'.ui':            FileType{
			icon:        ''
			color:       '#015BF0'
			cterm_color: '27'
			name:        'UI'
		}
		'.v':             FileType{
			icon:        ''
			color:       '#4F87FF'
			cterm_color: '27'
			name:        'VLang'
		}
		// who even uses Verilog anyway
		// '.v':             FileType{
		// 	icon:        '󰍛'
		// 	color:       '#019833'
		// 	cterm_color: '28'
		// 	name:        'Verilog'
		// }
		'.vala':          FileType{
			icon:        ''
			color:       '#7B3DB9'
			cterm_color: '91'
			name:        'Vala'
		}
		'.vert':          FileType{
			icon:        ''
			color:       '#5586A6'
			cterm_color: '67'
			name:        'VertexShader'
		}
		'.vh':            FileType{
			icon:        '󰍛'
			color:       '#019833'
			cterm_color: '28'
			name:        'Verilog'
		}
		'.vhd':           FileType{
			icon:        '󰍛'
			color:       '#019833'
			cterm_color: '28'
			name:        'VHDL'
		}
		'.vhdl':          FileType{
			icon:        '󰍛'
			color:       '#019833'
			cterm_color: '28'
			name:        'VHDL'
		}
		'.vi':            FileType{
			icon:        ''
			color:       '#FEC60A'
			cterm_color: '220'
			name:        'LabView'
		}
		'.vim':           FileType{
			icon:        ''
			color:       '#019833'
			cterm_color: '28'
			name:        'Vim'
		}
		'.vsh':           FileType{
			icon:        ''
			color:       '#5D87BF'
			cterm_color: '67'
			name:        'Vlang'
		}
		'.vsix':          FileType{
			icon:        ''
			color:       '#854CC7'
			cterm_color: '98'
			name:        'Vsix'
		}
		'.vue':           FileType{
			icon:        ''
			color:       '#8DC149'
			cterm_color: '113'
			name:        'Vue'
		}
		'.wasm':          FileType{
			icon:        ''
			color:       '#5C4CDB'
			cterm_color: '62'
			name:        'Wasm'
		}
		'.wav':           FileType{
			icon:        ''
			color:       '#00AFFF'
			cterm_color: '39'
			name:        'WaveformAudioFile'
		}
		'.webm':          FileType{
			icon:        ''
			color:       '#FD971F'
			cterm_color: '208'
			name:        'Webm'
		}
		'.webmanifest':   FileType{
			icon:        ''
			color:       '#F1E05A'
			cterm_color: '185'
			name:        'Webmanifest'
		}
		'.webp':          FileType{
			icon:        ''
			color:       '#A074C4'
			cterm_color: '140'
			name:        'Webp'
		}
		'.webpack':       FileType{
			icon:        '󰜫'
			color:       '#519ABA'
			cterm_color: '74'
			name:        'Webpack'
		}
		'.wma':           FileType{
			icon:        ''
			color:       '#00AFFF'
			cterm_color: '39'
			name:        'WindowsMediaAudio'
		}
		'.wmv':           FileType{
			icon:        ''
			color:       '#FD971F'
			cterm_color: '208'
			name:        'WindowsMediaVideo'
		}
		'.woff':          FileType{
			icon:        ''
			color:       '#ECECEC'
			cterm_color: '255'
			name:        'WebOpenFontFormat'
		}
		'.woff2':         FileType{
			icon:        ''
			color:       '#ECECEC'
			cterm_color: '255'
			name:        'WebOpenFontFormat'
		}
		'.wrl':           FileType{
			icon:        '󰆧'
			color:       '#888888'
			cterm_color: '102'
			name:        'VRML'
		}
		'.wrz':           FileType{
			icon:        '󰆧'
			color:       '#888888'
			cterm_color: '102'
			name:        'VRML'
		}
		'.wv':            FileType{
			icon:        ''
			color:       '#00AFFF'
			cterm_color: '39'
			name:        'WavPack'
		}
		'.wvc':           FileType{
			icon:        ''
			color:       '#00AFFF'
			cterm_color: '39'
			name:        'WavPackCorrection'
		}
		'.x':             FileType{
			icon:        ''
			color:       '#599EFF'
			cterm_color: '111'
			name:        'Logos'
		}
		'.xaml':          FileType{
			icon:        '󰙳'
			color:       '#512BD4'
			cterm_color: '56'
			name:        'Xaml'
		}
		'.xcf':           FileType{
			icon:        ''
			color:       '#635B46'
			cterm_color: '240'
			name:        'GIMP'
		}
		'.xcplayground':  FileType{
			icon:        ''
			color:       '#E37933'
			cterm_color: '166'
			name:        'XcPlayground'
		}
		'.xcstrings':     FileType{
			icon:        ''
			color:       '#2596BE'
			cterm_color: '31'
			name:        'XcLocalization'
		}
		'.xls':           FileType{
			icon:        '󰈛'
			color:       '#207245'
			cterm_color: '29'
			name:        'Xls'
		}
		'.xlsx':          FileType{
			icon:        '󰈛'
			color:       '#207245'
			cterm_color: '29'
			name:        'Xlsx'
		}
		'.xm':            FileType{
			icon:        ''
			color:       '#519ABA'
			cterm_color: '74'
			name:        'Logos'
		}
		'.xml':           FileType{
			icon:        '󰗀'
			color:       '#E37933'
			cterm_color: '166'
			name:        'Xml'
		}
		'.xpi':           FileType{
			icon:        ''
			color:       '#FF1B01'
			cterm_color: '196'
			name:        'Xpi'
		}
		'.xul':           FileType{
			icon:        ''
			color:       '#E37933'
			cterm_color: '166'
			name:        'Xul'
		}
		'.xz':            FileType{
			icon:        ''
			color:       '#ECA517'
			cterm_color: '214'
			name:        'Xz'
		}
		'.yaml':          FileType{
			icon:        ''
			color:       '#6D8086'
			cterm_color: '66'
			name:        'Yaml'
		}
		'.yml':           FileType{
			icon:        ''
			color:       '#6D8086'
			cterm_color: '66'
			name:        'Yml'
		}
		'.zig':           FileType{
			icon:        ''
			color:       '#F69A1B'
			cterm_color: '172'
			name:        'Zig'
		}
		'.zip':           FileType{
			icon:        ''
			color:       '#ECA517'
			cterm_color: '214'
			name:        'Zip'
		}
		'.zsh':           FileType{
			icon:        ''
			color:       '#89E051'
			cterm_color: '113'
			name:        'Zsh'
		}
		'.zst':           FileType{
			icon:        ''
			color:       '#ECA517'
			cterm_color: '214'
			name:        'Zst'
		}
		'.🔥':            FileType{
			icon:        ''
			color:       '#FF4C1F'
			cterm_color: '196'
			name:        'Mojo'
		}
	}
}
