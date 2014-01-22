@Fixtures ?= {}

Fixtures.AjaxForm = "
<form action='/sessions' method='post'>
  <select name='user[civility]'>
    <option value='Ms'>Ms</option>
    <option value='Mr'>Mr</option>
  </select>
  <input name='user[email]' type='text'>
  <input name='user[password]' type='password'>
  <input type='submit'>
</form>
"
