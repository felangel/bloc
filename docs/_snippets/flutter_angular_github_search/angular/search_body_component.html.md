```html
<div *ngIf="state != null" class="mw10">
  <div *ngIf="isEmpty" class="tc">
    <material-icon icon="info" class="light-blue"></material-icon>
    <p>Please enter a term to begin</p>
  </div>
  <div *ngIf="isLoading" class="tc"><material-spinner></material-spinner></div>
  <div *ngIf="isError" class="tc">
    <material-icon icon="error" class="light-red"></material-icon>
    <p>{{ error }}</p>
  </div>
  <div *ngIf="isSuccess">
    <div *ngIf="items.length == 0" class="tc">
      <material-icon icon="warning" class="light-yellow"></material-icon>
      <p>No Results</p>
    </div>
    <search-results [items]="items"></search-results>
  </div>
</div>
```
