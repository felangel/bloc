```html
<div>
  <h1>Github Search</h1>
  <search-bar [githubSearchBloc]="githubSearchBloc"></search-bar>
  <search-body [state]="githubSearchBloc | bloc"></search-body>
</div>
```
