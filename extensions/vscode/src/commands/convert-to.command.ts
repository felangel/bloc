import { convertTo } from "../utils";

const multiBlocProviderSnippet = (widget: string, child: string) => {
  return `MultiBlocProvider(
    providers: [
        ${widget},
        BlocProvider(
            create: (context) => \${1:Subject}\${2|Bloc,Cubit|}(),
        ),
    ],
    ${child}
)`;
};

const multiBlocListenerSnippet = (widget: string, child: string) => {
  return `MultiBlocListener(
    listeners: [
        ${widget},
        BlocListener<\${1:Subject}\${2|Bloc,Cubit|}, \$1State>(
            listener: (context, state) {
                \${4:// TODO: implement listener}
            },
        ),
    ],
    ${child}
)`;
};

const multiRepositoryProviderSnippet = (widget: string, child: string) => {
  return `MultiRepositoryProvider(
    providers: [
        ${widget},
        RepositoryProvider(
            create: (context) => \${1:Subject}Repository(),
        ),
    ],
    ${child}
)`;
};

export const convertToMultiBlocProvider = async () =>
  convertTo(multiBlocProviderSnippet);
export const convertToMultiBlocListener = async () =>
  convertTo(multiBlocListenerSnippet);
export const convertToMultiRepositoryProvider = async () =>
  convertTo(multiRepositoryProviderSnippet);
