-- API keys dos serviços internos, geradas pelo Terraform (random_password)
-- Só o hash chega aqui (variável do psql vinda do Secret); a chave em si fica no Secret do serviço
-- ON CONFLICT: o Job roda a cada sync, então a inserção precisa ser idempotente
INSERT INTO api_keys (name, key_hash)
VALUES ('evaluation-service', :'evaluation_key_hash')
ON CONFLICT (key_hash) DO NOTHING;
