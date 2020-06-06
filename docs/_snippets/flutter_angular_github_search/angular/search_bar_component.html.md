```html
<label for="term" class="clip">Enter a search term</label>
<input
  id="term"
  placeholder="Enter a search term"
  class="input-reset outline-transparent glow o-50 bg-near-black near-white w-100 pv2 border-box b--white-50 br-0 bl-0 bt-0 bb-ridge mb3"
  autofocus
  (keyup)="onTextChanged($event.target.value)"
/>
```
