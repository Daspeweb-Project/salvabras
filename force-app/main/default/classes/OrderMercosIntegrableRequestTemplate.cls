public class OrderMercosIntegrableRequestTemplate{
    public Integer cliente_id;	//14
    public String data_emissao;	//2017-02-20
    public String data_criacao;	//2017-02-20 14:07:45
    public Integer contato_id;	//9
    public Integer transportadora_id;	//8
    public Integer endereco_entrega_id;	//17
    public Integer condicao_pagamento_id;	//5
    public Integer tipo_pedido_id;	//97
    public Integer forma_pagamento_id;	//1
    public String rastreamento;	//BB000000000000BR
    public Integer valor_frete;	//0
    public String observacoes;	//Envio após 1 dia útil.
   // public cls_extras[] extras;
    public cls_itens[] itens;
    /*class cls_extras {
        public Integer id;	//1
        public String valor;	//2017-02-21
    }*/
    public class cls_itens {
        public Integer id;	//2
        
        public Integer produto_id;	//2
        public Integer tabela_preco_id;	//2323
        public Double quantidade;	//21.5
        public DOuble preco_tabela;	//1
        public String observacoes;	//teste
    }
    
    
}