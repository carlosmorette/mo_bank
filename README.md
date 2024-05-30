# MoBank                                                                                                                                                                         
                                                                                                                                                                                 
`MoBank` é um sistema de gestão bancário que possui essencialmente 3 funcionalidades:                                                                                            
- Criar "conta"                                                                                                                                                                  
- Consultar "conta"                                                                                                                                                              
- Realizar "transação"                                                                                                                                                           
                                                                                                                                                                                 
As três funcionalidades mencionadas acima estão disponibilizadas em três endpoints, que são:                                                                                      
- `POST /conta` - Criar conta                                                                                                                                                      
- `GET /conta:numero_conta` - Consultar dados de uma conta                                                                                                                         
- `POST /transacao` - Realizar uma transação                                                                                                                                       
                                                                                                                                                                                 
## Quero brincar, o que eu faço?                                                                                                                                                 
Para iniciar o projeto será necessário ter instalado o banco de dados [PostgreSQL](https://www.postgresql.org/) e o [Elixir](https://elixir-lang.org/).                         
                                                                                                                                                                                 
Para iniciar o projeto Phoenix:                                                                                                                                                  
  * Rode `mix setup` para instalar as dependências necessárias e configurar o banco de dados                                                                                     
  * Inicie o endpoint Phoenix com `mix phx.server` ou dentro do IEx com `iex -S mix phx.server`                                                                                  
                                                                                                                                                                                 
Agora você consegue acessar [`localhost:4000`](http://localhost:4000) e utilizar as funcionalidades expostas na API mencionadas acima.                                     
