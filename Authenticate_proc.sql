procedure authenticate
is
  t_seconds_left  number;
  cursor c_oauth_user
  is     select c.n001 - ((sysdate - c.d001) * 24 * 60 * 60) as seconds_left
         from   apex_collections c
         where  c.collection_name = s4sa_oauth_pck.g_settings.collection_name
           and  c.c001            = 'LINKEDIN';
begin

  open c_oauth_user;
  fetch c_oauth_user into t_seconds_left;
  close c_oauth_user;
    
  if not nvl(t_seconds_left, 0) > 0 then
    redirect_oauth2(p_gotopage => v('APP_PAGE_ID'));
  end if;
    
end authenticate;