trigger CotacaoTrigger on Quote (before update) {
    if(Trigger.isUpdate){
        Set<Id> idsQuote = Trigger.newMap.keyset();
        List<Opportunity> opps = new List<Opportunity>();
        Set<id> idsOpp = new Set<Id>();
        for(Quote quot : Trigger.New){
            idsOpp.add(quot.OpportunityId);
        }
        opps = [SELECT Id,Stagename,Amount,CloseDate,OwnerId FROM Opportunity WHERE Id IN: idsOpp];
        Map<id, Date> closeDatebyId = new Map<Id, Date>();
        for(Opportunity opp : opps){
            closeDateById.put(opp.id, opp.closeDate);
        }
        List<QuoteLineItem> itensQuote = [SELECT IPI__c,Discount,UnitPrice,Quantity,Quote.Discount,QuoteId,Product2.IPI__c,Product2.Custo_de_Produto_Pro__c, Product2.Custo_de_Produto_Bras__c,PricebookEntry.Pricebook2.ICMS_Simples__c from QuoteLineItem WHERE QuoteId IN: idsQuote];
        if(itensQuote.size() > 0){
            List<Cotacao_indicadores__mdt> cotacoes = [SELECT DeveloperName, Valor__c from Cotacao_indicadores__mdt WHERE DeveloperName = 'Frete_sobre_vendas' OR DeveloperName = 'MarkUp'];
            Decimal cot_markup = 0;
            Decimal cot_frete_vendas = 0;
            for(Cotacao_indicadores__mdt cotacao : cotacoes){
                if(cotacao.DeveloperName == 'Markup'){
                    cot_markup = cotacao.Valor__c/100;
                }else if(cotacao.DeveloperName == 'Frete_sobre_vendas'){
                    cot_frete_vendas = cotacao.Valor__c/100;
                }
            }
            Map<Id, List<QuoteLineItem>> itensPorQuote = new Map<Id, List<QuoteLineItem>>();
            for(QuoteLineItem item : itensQuote){
                if(itensPorQuote.get(item.QuoteId) != null){
                    List<QuoteLineItem> itens = itensPorQuote.get(item.QuoteId);
                    itens.add(item);
                    itensPorQuote.put(item.QuoteId, itens);
                }else{
                    List<QuoteLineItem> itens = new List<QuoteLineItem>();
                    itens.add(item);
                    itensPorQuote.put(item.QuoteId, itens);
                }
            }
            for(Quote quot : Trigger.New){
                List<QuoteLineItem> itens = itensPorQuote.get(quot.Id);
                Decimal Quantidade = 0;
                Decimal Subtotal_com_desconto = 0;
                Decimal Valor_IPI = 0;
                Decimal Valor_ICMS = 0;
                Decimal Valor_Pis = 0;
                Decimal Valor_Cofins = 0;
                Decimal Valor_IRPJ = 0;
                Decimal Valor_CSLL = 0;
                Decimal Custo_Produto = 0;
                Decimal Valor_Simples_Nacional = 0;
                if(itens.size()> 0){
                    for(QuoteLineItem item : itens){
                        Quantidade += item.Quantity;
                    }
                    
                    for(QuoteLineItem item : itens){
                        Decimal valor_frete_item = (quot.Tipo_de_Frete__c == 'CIF') ? ((quot.Valor_do_Frete__c / Quantidade) * item.Quantity) : 0;
                        Decimal subtotal_item = (item.Quantity * item.UnitPrice * (1-(((item.Discount != null) ? item.Discount : 0)/100))) + valor_frete_item;
                        if(quot.Cota_o_SalvaBras__c){
                            Decimal Valor_IPI_item = subtotal_item - (subtotal_item / (1+(item.IPI__c/100)));
                            Decimal Valor_ICMS_item = (subtotal_item - Valor_IPI_item) * CotacaoUtil.transformarProcentagem(item.PricebookEntry.Pricebook2.ICMS_Simples__c);
                            Decimal Valor_Pis_item = (subtotal_item - Valor_IPI_item) * (0.0065);
                            Decimal Valor_Cofins_item = (subtotal_item - Valor_IPI_item) * 0.03;
                            Decimal Valor_IRPJ_item = (subtotal_item - Valor_IPI_item) * 0.02;
                            Decimal Valor_CSLL_item = (subtotal_item - Valor_IPI_item) * (0.0108);
                            Decimal Custo_Produto_item = item.Quantity * item.Product2.Custo_de_Produto_Bras__c;
                            Valor_IPI += Valor_IPI_item;
                            Valor_ICMS += Valor_ICMS_item;
                            Valor_Pis += Valor_Pis_item;
                            Valor_Cofins += Valor_Cofins_item;
                            Valor_IRPJ += Valor_IRPJ_item;
                            Valor_CSLL += Valor_CSLL_item;
                            Custo_Produto += Custo_Produto_item;
                        }else{
                            Decimal Custo_Produto_item = item.Quantity * item.Product2.Custo_de_Produto_Pro__c;
                            Decimal Valor_Simples_Nacional_item = subtotal_item * 0.12;
                            Valor_Simples_Nacional += Valor_Simples_Nacional_item;
                            Custo_Produto += Custo_Produto_item;
                        }
                    Subtotal_com_desconto += subtotal_item;
                    }
                }
                quot.Subtotal_com_desconto__c = Subtotal_com_desconto;
                quot.Valor_IPI__c = Valor_IPI;
                quot.Valor_ICMS__c = Valor_ICMS;
                quot.Valor_Pis__c = Valor_Pis;
                quot.Valor_Cofins__c = Valor_Cofins;
                quot.Valor_IRPJ__c = Valor_IRPJ;
                quot.Valor_CSLL__c = Valor_CSLL;
                quot.Valor_Simples_Nacional__c = Valor_Simples_Nacional;
                
                quot.Frete_sobre_vendas__c = (quot.Frete_Grande_SP__c) ? (quot.Subtotal_com_desconto__c - quot.Valor_IPI__c ) * cot_frete_vendas : 0;
                quot.Valor_comissao__c = (quot.Subtotal_com_desconto__c - quot.Valor_IPI__c)*(quot.Comiss_o_da_Cota_o__c/100);
                quot.Custo_financeiro__c = quot.Subtotal_com_desconto__c *(quot.TaxaJurosPeriodo__c!= null ? quot.TaxaJurosPeriodo__c : 100)/ 100;
                quot.Custo_contrato__c = (quot.Contrato_Cliente__c != null) ? (quot.Subtotal_com_desconto__c * quot.Contrato_Cliente__c/100) : 0;
                quot.MarkUp__c = (quot.Subtotal_com_desconto__c - quot.Valor_IPI__c) * cot_markup;
                if(closeDateById.get(quot.OpportunityId).month() == System.now().month()){
                	quot.Custo_Produto__c = Custo_Produto;
                    quot.Lucro__c = quot.Subtotal_com_desconto__c - (quot.Valor_IPI__c + quot.Custo_contrato__c + quot.Valor_ICMS__c + quot.Valor_Pis__c + quot.Valor_Cofins__c + quot.Valor_IRPJ__c + quot.Valor_CSLL__c + quot.Valor_Simples_Nacional__c + quot.Valor_comissao__c + quot.Frete_sobre_vendas__c + quot.Custo_financeiro__c + quot.MarkUp__c + quot.Custo_Produto__c + ((quot.Tipo_de_Frete__c == 'CIF') ? quot.Valor_do_Frete__c : 0));
                    quot.P_lucro__c = (quot.Lucro__c / (quot.Subtotal_com_desconto__c - quot.Valor_IPI__c))*100;
                }
            }
        }
        MetaUtil.separar_opportunidades(opps, null);
    }
}