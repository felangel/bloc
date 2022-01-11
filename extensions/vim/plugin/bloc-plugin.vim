" bloc generator
" 1 - Mappings
nnoremap K :BlocPlugin
nnoremap K :CubitPlugin

function SearchAndReplace(...)
        let search = a:000[0]
        let replace = a:000[1]
        let type = a:000[2]
        let path = a:000[3]
        let fileName = a:000[4]

        let stringCommand = "sed -i'.bak' 's/" . search . "/" . replace . "/gi' " . path . "/" . type . "/" . fileName
        call system(stringCommand)
endfunction

function RenameAndDeleteFiles(...)
        let allFiles =  split(a:000[0])
        let type = a:000[1]
        let name = a:000[2]
        let path = a:000[3]
        let snakeCaseName = substitute(name, '\u', '_\l&', "g")[1:]

        for i in allFiles
                call SearchAndReplace("<rename_file>", snakeCaseName, type, path, i)
                call SearchAndReplace("<rename>", name, type, path, i)

                let destinationName = snakeCaseName . "_" . i
                let renameSource = "mv " . path . "/" . type . "/" . i . " " . path .  "/" . type . "/" . destinationName
                call system(renameSource)

                let deleteFile = "rm " . path . "/" . type . "/" . i . ".bak"
                call system(deleteFile)
        endfor

        let remoGit = "rm -rf " . path . "/" . type . "/.git"
        call system(remoGit)

endfunction

function! BlocPlugin(...)
        let args = split(a:000[0])

        if len(args) < 2
                echo "You must pass the BlocName and destinationPath like ':Bloc BlocName lib/feature_Name'"
        else
                let blocName = args[0]
                let path = args[1]
                let command = "git clone https://github.com/eliasreis54/vim_bloc_plugin_source.git " . path . "/bloc/"
                let scriptPath = fnamemodify(resolve(expand('<sfile>:p')), ':h')

                let copyCommand = "cp " . scriptPath . "/source/bloc/* " . path . "/bloc/"

                echo copyCommand

                call system(command)

                call RenameAndDeleteFiles("bloc.dart state.dart event.dart", 'bloc', blocName, path)
                echo "Bloc: All done"
        endif
endfunction

function! CubitPlugin(...)
        let args = split(a:000[0])

        if len(args) < 2
                echo "You must pass the CubitName and destinationPath like ':Cubit CubitName lib/feature_Name'"
        else
                let cubitName = args[0]
                let path = args[1]
                let command = "git clone https://github.com/eliasreis54/vim_bloc_plugin_cubit_source.git " . path . "/cubit/"

                call system(command)

                call RenameAndDeleteFiles("cubit.dart state.dart", "cubit", cubitName, path)
                echo "Cubit: All done"
        endif
endfunction

" Commands
command! -nargs=* Bloc call BlocPlugin(<q-args>)

command! -nargs=* Cubit call CubitPlugin(<q-args>)
