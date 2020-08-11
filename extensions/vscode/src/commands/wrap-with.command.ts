import { wrapWith } from "../utils";

const blocBuilderSnippet = (widget: string) => {
  return `BlocBuilder<\${1:Subject}\${2|Bloc,Cubit|}, $1State>(
  builder: (context, state) {
    return ${widget};
  },
)`;
};

const blocListenerSnippet = (widget: string) => {
  return `BlocListener<\${1:Subject}\${2|Bloc,Cubit|}, $1State>(
  listener: (context, state) {
    \${3:// TODO: implement listener}
  },
  child: ${widget},
)`;
};

const blocProviderSnippet = (widget: string) => {
  return `BlocProvider(
  create: (context) => \${1:Subject}\${2|Bloc,Cubit|}(),
  child: ${widget},
)`;
};

const blocConsumerSnippet = (widget: string) => {
  return `BlocConsumer<\${1:Subject}\${2|Bloc,Cubit|}, $1State>(
  listener: (context, state) {
    \${3:// TODO: implement listener}
  },
  builder: (context, state) {
    return ${widget};
  },
)`;
};

const repositoryProviderSnippet = (widget: string) => {
  return `RepositoryProvider(
  create: (context) => \${1:Subject}Repository(),
    child: ${widget},
)`;
};

export const wrapWithBlocBuilder = async () => wrapWith(blocBuilderSnippet);
export const wrapWithBlocListener = async () => wrapWith(blocListenerSnippet);
export const wrapWithBlocConsumer = async () => wrapWith(blocConsumerSnippet);
export const wrapWithBlocProvider = async () => wrapWith(blocProviderSnippet);
export const wrapWithRepositoryProvider = async () =>
  wrapWith(repositoryProviderSnippet);
