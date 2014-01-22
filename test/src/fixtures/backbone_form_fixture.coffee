@Fixtures ?= {}

Fixtures.BackboneForm = "
<form>
  <input name='first_name' type='text'>
  <select name='country_id'>
    <option value='1'>1</option>
    <option value='2'>2</option>
  </select>
  <input name='main_address' type='hidden' value='false'>
  <input name='main_address' type='checkbox' value='true'>
  <input type='submit'>
</form>
"
