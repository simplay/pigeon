insert into tokens
( server_id,
  token_key,
  token_type,
  token_id1,
  token_id2,
  token_created,
  token_description,
  token_customset,
  token_from_client_id)
VALUES 
( :server_id:,
  :token_key:,
  :token_type:,
  :token_id1:,
  :token_id2:,
  :token_created:,
  :token_description:,
  :token_customset:,
  :token_from_client_id:);
