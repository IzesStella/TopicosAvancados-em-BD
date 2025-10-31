import psycopg2
import sys

DB_NAME = "meu_banco"
DB_USER = "postgres"
DB_PASS = "050390"
DB_HOST = "localhost"
DB_PORT = "5432"

def main():
    conn = None
    try:
        conn = psycopg2.connect(
            dbname=DB_NAME,
            user=DB_USER,
            password=DB_PASS,
            host=DB_HOST,
            port=DB_PORT
        )
        print(f"Conectado ao banco '{DB_NAME}' com sucesso.")
        
    
        conn.autocommit = True
        cursor = conn.cursor()

        print("\n--- INICIANDO TESTE (TRIGGER DE VALIDAÇÃO DE PREÇO) ---")

        # 1: Inserir dados MÍNIMOS (Usuário, Loja, Categoria)
        cursor.execute("INSERT INTO Usuarios (nome, email, senha) VALUES ('Dono', 'dono@loja.com', '123') RETURNING usuario_id")
        usuario_id = cursor.fetchone()[0]
        
        cursor.execute("INSERT INTO Lojas (usuario_dono_id, nome_loja) VALUES (%s, 'Loja Principal') RETURNING loja_id", (usuario_id,))
        loja_id = cursor.fetchone()[0]

        cursor.execute("INSERT INTO Categorias (nome_categoria) VALUES ('Eletrônicos') RETURNING categoria_id")
        categoria_id = cursor.fetchone()[0]
        
        print("PASSO 1: Dados mínimos (Usuário, Loja, Categoria) criados.")

    #trigger
        print("\n" + "="*50)
        print("DEMONSTRAÇÃO DO TRIGGER 'BEFORE INSERT'")
        
        # 2: Teste Válido 
        preco_valido = 1999.90
        print(f"\nPASSO 2: Tentando inserir produto com preço VÁLIDO (R$ {preco_valido})...")
        try:
            cursor.execute(
                """
                INSERT INTO Produtos (loja_id, categoria_id, nome_produto, preco) 
                VALUES (%s, %s, %s, %s)
                """,
                (loja_id, categoria_id, 'Notebook', preco_valido)
            )
            print("[SUCESSO] Produto com preço válido foi inserido.")
        except Exception as error:
            print(f"[FALHA] O insert válido falhou: {error}")


        # PASSO 3: Teste para erro (Deve falhar)
        # Tentamos inserir um produto com preço R$ 0.00. O esperado é que o try falhe
        preco_invalido = 0.00
        print(f"\nPASSO 3: Tentando inserir produto com preço INVÁLIDO (R$ {preco_invalido})...")
        
        try:
            cursor.execute(
                """
                INSERT INTO Produtos (loja_id, categoria_id, nome_produto, preco) 
                VALUES (%s, %s, %s, %s)
                """,
                (loja_id, categoria_id, 'Mousepad', preco_invalido)
            )
            # Se chegar aqui, o trigger falhou
            print("[FALHA] O trigger NÃO funcionou. O produto foi inserido com preço zero.")
        
        except psycopg2.Error as error:
            # Se entrar aqui, o trigger funcionou e o banco retornou um erro
            print(f"\n[SUCESSO] O trigger funcionou!")
            print(f"O banco de dados bloqueou a inserção e retornou o seguinte erro:")
            print(f"-> {error.pgerror}")

        print("\n" + "="*50)

    except Exception as error:
        print(f"\nERRO GERAL: {error}")
    finally:
        # Fecha a conexão
        if conn:
            cursor.close()
            conn.close()
            print("\nConexão fechada.")

if __name__ == "__main__":
    main()
