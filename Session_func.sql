function invalid_session
  ( p_authentication in apex_plugin.t_authentication
  , p_plugin         in apex_plugin.t_plugin 
  ) return apex_plugin.t_authentication_inval_result
is
  t_retval apex_plugin.t_authentication_inval_result;
begin

  redirect_oauth2(p_gotopage => v('APP_PAGE_ID'));
      
  return t_retval;
end invalid_session;