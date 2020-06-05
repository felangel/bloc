```html
<div class="counter-page-container">
  <h1>Counter App</h1>
  <h2>Current Count: {{ counterBloc | bloc }}</h2>
  <button class="counter-button" (click)="increment()">➕</button>
  <button class="counter-button" (click)="decrement()">➖</button>
</div>
```
