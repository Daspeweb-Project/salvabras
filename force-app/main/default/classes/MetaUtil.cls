public with sharing class MetaUtil {
    public static String GANHO = 'F5 - Ganho';

    public static void criar_metas_semanais(List<Meta__c> metas){
        Set<Id> idsMetas = new Set<id>();
        Set<Id> idsUsuario = new Set<id>();
        List<Meta_semanal__c> metas_semanais_criar = new List<Meta_semanal__c>();
        Map<Id, Date> inicio_mes_por_meta = new map<Id, Date>();
        Map<Id, Date> fim_mes_por_meta = new map<Id, Date>();
        Date menor_inicio = null;
        Date maior_fim = null;
        for(Meta__c meta : metas){
            idsMetas.add(meta.Id);
            idsUsuario.add(meta.Usuario__c);
            Date inicioMes = Date.newInstance((Integer)meta.Ano__c, (Integer)meta.Numero_mes__c, 1);
            Date fimMes = Date.newInstance((Integer)meta.Ano__c, 12, 31);
            if(meta.Numero_mes__c != 12){
                fimMes = Date.newInstance((Integer)meta.Ano__c, (Integer)meta.Numero_mes__c+1, 1).addDays(-1);
            }
            inicio_mes_por_meta.put(meta.Id, inicioMes);
            fim_mes_por_meta.put(meta.Id, fimMes);
            if(menor_inicio == null || menor_inicio > inicioMes){
                menor_inicio = inicioMes;
            }
            if(maior_fim == null || maior_fim < fimMes){
                maior_fim = fimMes;
            }
        }

        List<Meta_semanal__c> metas_semanais = [SELECT Id,Name,Meta__c,Inicio_da_semana__c from Meta_semanal__c WHERE Meta__c IN: idsMetas];
        if(metas_semanais.size() > 0) delete metas_semanais;
        Map<String, Meta_semanal__c> meta_semanal_por_meta_nome = new Map<String, Meta_semanal__c>();
        Map<id, List<Meta_semanal__c>> metas_semanais_por_meta = new Map<Id,List<Meta_semanal__c>>();
        for(Meta_semanal__c meta_semanal : metas_semanais){
            if(metas_semanais_por_meta.get(meta_semanal.Meta__c) != null){
                List<Meta_semanal__c> metas_semanaisList = metas_semanais_por_meta.get(meta_semanal.Meta__c);
                metas_semanaisList.add(meta_semanal);
                metas_semanais_por_meta.put(meta_semanal.Meta__c, metas_semanaisList);
            }else{
                List<Meta_semanal__c> metas_semanaisList = new List<Meta_semanal__c>();
                metas_semanaisList.add(meta_semanal);
                metas_semanais_por_meta.put(meta_semanal.Meta__c, metas_semanaisList);
            }
        }
        Businesshours bh = [SELECT id,MondayStartTime FROM businesshours WHERE isdefault= true];
        for(Meta__c meta : metas){
            Integer dias_uteis_mes = 0;
            Date data = inicio_mes_por_meta.get(meta.Id);
            Date fim = fim_mes_por_meta.get(meta.Id);
            Map<String, Integer> qut_dias_uteis = new Map<String, Integer>();
            Map<String, String> dias_uteisMap = new Map<String, String>();
            while(data <= fim){
                Integer dias_uteis = 0;
                Date inicioSemana = data.toStartofWeek();
                if(inicioSemana < inicio_mes_por_meta.get(meta.Id)){
                    inicioSemana = inicio_mes_por_meta.get(meta.Id);
                    if(!MetaUtil.dia_nao_util(inicioSemana, bh)){
                        dias_uteis += 1;
                        if(dias_uteisMap.get(inicioSemana.day()+'/'+meta.Numero_mes__c+'/'+meta.Ano__c+'&&'+meta.Usuario__c) == null){
                            String str_dias_uteis = String.valueOf(data.day());
                            dias_uteisMap.put(inicioSemana.day()+'/'+meta.Numero_mes__c+'/'+meta.Ano__c+'&&'+meta.Usuario__c, str_dias_uteis);
                        }
                    }
                }
                if(qut_dias_uteis.get(inicioSemana.day()+'/'+meta.Numero_mes__c+'/'+meta.Ano__c+'&&'+meta.Usuario__c) != null){
                    dias_uteis = qut_dias_uteis.get(inicioSemana.day()+'/'+meta.Numero_mes__c+'/'+meta.Ano__c+'&&'+meta.Usuario__c);
                    if(!MetaUtil.dia_nao_util(data, bh)){
                        dias_uteis += 1;
                        if(dias_uteisMap.get(inicioSemana.day()+'/'+meta.Numero_mes__c+'/'+meta.Ano__c+'&&'+meta.Usuario__c) != null){
                            String str_dias_uteis = dias_uteisMap.get(inicioSemana.day()+'/'+meta.Numero_mes__c+'/'+meta.Ano__c+'&&'+meta.Usuario__c);
                            str_dias_uteis += ', '+data.day();
                            dias_uteisMap.put(inicioSemana.day()+'/'+meta.Numero_mes__c+'/'+meta.Ano__c+'&&'+meta.Usuario__c, str_dias_uteis);
                        }else{
                            String str_dias_uteis = String.valueOf(data.day());
                            dias_uteisMap.put(inicioSemana.day()+'/'+meta.Numero_mes__c+'/'+meta.Ano__c+'&&'+meta.Usuario__c, str_dias_uteis);
                        }
                    }
                }
                qut_dias_uteis.put(inicioSemana.day()+'/'+meta.Numero_mes__c+'/'+meta.Ano__c+'&&'+meta.Usuario__c, dias_uteis);
                data = data.addDays(1);
            }
            for(String dia : qut_dias_uteis.keySet()){
                dias_uteis_mes += qut_dias_uteis.get(dia);
            }

            Decimal valor_dia_util = meta.Valor__c/dias_uteis_mes;
            Decimal quant_isolamento = (meta.Quantidade_isolamento_ambientes__c != null) ? meta.Quantidade_isolamento_ambientes__c/dias_uteis_mes : 0;
            Decimal quant_mascaramento = (meta.Quantidade_mascaramento_pintura__c != null) ? meta.Quantidade_mascaramento_pintura__c/dias_uteis_mes : 0;
            Decimal quant_materiais_basico = (meta.Quantidade_materiais_basico__c != null) ? meta.Quantidade_materiais_basico__c/dias_uteis_mes : 0;
            Decimal quant_protecao_bancadas = (meta.Quantidade_protecao_bancadas__c != null) ? meta.Quantidade_protecao_bancadas__c/dias_uteis_mes : 0;
            Decimal quant_protecao_metais = (meta.Quantidade_protecao_metais__c != null) ? meta.Quantidade_protecao_metais__c/dias_uteis_mes : 0;
            Decimal quant_protecao_quinas = (meta.Quantidade_protecao_quinas_e_batentes__c != null) ? meta.Quantidade_protecao_quinas_e_batentes__c/dias_uteis_mes : 0;
            Decimal quant_protecao_tubulacoes = (meta.quantidade_protecao_tubulacoes__c != null) ? meta.quantidade_protecao_tubulacoes__c/dias_uteis_mes : 0;
            Decimal metr_protecao_pisos = (meta.Metragem_protecao_pisos__c != null) ? meta.Metragem_protecao_pisos__c/dias_uteis_mes : 0;

            Integer contador = 0;
            for(String dia : qut_dias_uteis.keySet()){
                contador += 1;
                Meta_semanal__c meta_semanal_criar = new Meta_semanal__c();
                meta_semanal_criar.Meta__c = meta.Id;
                meta_semanal_criar.Dias_uteis__c = qut_dias_uteis.get(dia);
                meta_semanal_criar.name = 'Semana '+contador + ' de ' + meta.Mes__c;
                meta_semanal_criar.Inicio_da_semana__c = Decimal.valueOf(dia.split('/')[0]);
                meta_semanal_criar.Dias_uteis_da_semana__c = dias_uteisMap.get(dia);
                meta_semanal_criar.Valor__c = qut_dias_uteis.get(dia)*valor_dia_util;
                meta_semanal_criar.Quantidade_isolamento_ambientes__c = qut_dias_uteis.get(dia)*quant_isolamento;
                meta_semanal_criar.Quantidade_mascaramento_pintura__c = qut_dias_uteis.get(dia)*quant_mascaramento;
                meta_semanal_criar.Quantidade_materiais_basico__c = qut_dias_uteis.get(dia)*quant_materiais_basico;
                meta_semanal_criar.Quantidade_protecao_bancadas__c = qut_dias_uteis.get(dia)*quant_protecao_bancadas;
                meta_semanal_criar.Quantidade_protecao_metais__c = qut_dias_uteis.get(dia)*quant_protecao_metais;
                meta_semanal_criar.Quantidade_protecao_quinas_e_batentes__c = qut_dias_uteis.get(dia)*quant_protecao_quinas;
                meta_semanal_criar.Quantidade_protecao_tubulacoes__c = qut_dias_uteis.get(dia)*quant_protecao_tubulacoes;
                meta_semanal_criar.Metragem_protecao_pisos__c = qut_dias_uteis.get(dia)*metr_protecao_pisos;
                if(meta_semanal_criar.Dias_uteis__c != 0)
                    metas_semanais_criar.add(meta_semanal_criar);
            }
        }

        insert metas_semanais_criar;
        Map<Id,List<Meta_semanal__c>> metas_semanais_por_meta_map = new Map<Id, List<Meta_semanal__c>>();
        for(Meta_semanal__c meta_semanal : metas_semanais_criar){
            if(metas_semanais_por_meta_map.get(meta_semanal.Meta__c) != null){
                List<Meta_semanal__c> metas_sem = metas_semanais_por_meta_map.get(meta_semanal.Meta__c);
                metas_sem.add(meta_semanal);
                metas_semanais_por_meta_map.put(meta_semanal.Meta__c, metas_sem);
            }else{
                List<Meta_semanal__c> metas_sem = new List<Meta_semanal__c>();
                metas_sem.add(meta_semanal);
                metas_semanais_por_meta_map.put(meta_semanal.Meta__c, metas_sem);
            }
        }
        List<Meta_diaria__c> metas_diarias = new List<Meta_diaria__c>();
        for(Meta__c meta : metas){
            if(metas_semanais_por_meta_map.get(meta.Id) != null){
                for(Meta_semanal__c meta_semanal : metas_semanais_por_meta_map.get(meta.Id)){
                    String[] dias_uteis_semana = meta_semanal.Dias_uteis_da_semana__c.split(', ');
                    for(String dia_util : dias_uteis_semana){
                        Meta_diaria__c meta_diaria = new Meta_diaria__c();
                        meta_diaria.Name = dia_util+' de '+meta.Mes__c+' de '+meta.Ano__c;
                        meta_diaria.Meta_semanal__c = meta_semanal.Id;
                        meta_diaria.Dia__c = Date.newInstance(Integer.valueOf(meta.Ano__c), Integer.valueOf(meta.Numero_mes__c), Integer.valueOf(dia_util));
                        meta_diaria.Valor_do_dia__c = meta_semanal.Valor__c/dias_uteis_semana.size();
                        meta_diaria.Quantidade_isolamento_ambientes__c = meta_semanal.Quantidade_isolamento_ambientes__c/dias_uteis_semana.size();
                        meta_diaria.Quantidade_mascaramento_pintura__c = meta_semanal.Quantidade_mascaramento_pintura__c/dias_uteis_semana.size();
                        meta_diaria.Quantidade_materiais_basico__c = meta_semanal.Quantidade_materiais_basico__c/dias_uteis_semana.size();
                        meta_diaria.Quantidade_protecao_bancadas__c = meta_semanal.Quantidade_protecao_bancadas__c/dias_uteis_semana.size();
                        meta_diaria.Quantidade_protecao_metais__c = meta_semanal.Quantidade_protecao_metais__c/dias_uteis_semana.size();
                        meta_diaria.Quantidade_protecao_quinas_e_batentes__c = meta_semanal.Quantidade_protecao_quinas_e_batentes__c/dias_uteis_semana.size();
                        meta_diaria.Quantidade_protecao_tubulacoes__c = meta_semanal.Quantidade_protecao_tubulacoes__c/dias_uteis_semana.size();
                        meta_diaria.Metragem_protecao_pisos__c = meta_semanal.Metragem_protecao_pisos__c/dias_uteis_semana.size();
                        metas_diarias.add(meta_diaria);
                    }
                }
            }
        }
        if(metas_diarias.size() > 0) insert metas_diarias;
        
        String jsonSerialize = JSON.serialize(idsUsuario) +';'+JSON.serialize(metas_semanais_criar) ; 
        atualizar_metas_usuario(jsonSerialize);
    }
    @future
    public static void atualizar_metas_usuario(String jsonResults){
        List<Id> idsUser = (List<Id>) JSON.deserialize(jsonResults.split(';')[0], List<Id>.class);
        List<Meta_semanal__c> metas_semanais_ids = (List<Meta_semanal__c>) JSON.deserialize(jsonResults.split(';')[1], List<Meta_semanal__c>.class);

        //Set<Id> idsUser, List<Meta_semanal__c> metas_semanais_ids
        List<Meta_diaria__c> metas_diarias_atualizar = new List<Meta_diaria__c>();
        List<Opportunity> opp_atualizar = new List<Opportunity>();
        List<Meta_diaria__c> metas_diarias;
        if(metas_semanais_ids.size() > 0){
            Set<id> ids_metas_semanais = (new Map<Id,Meta_semanal__c>(metas_semanais_ids)).keySet();
            metas_diarias = [SELECT Dia__c,Meta_semanal__c ,Meta_semanal__r.Valor__c,Meta_semanal__r.Inicio_da_semana__c,Meta_semanal__r.Meta__r.Ano__c, Meta_semanal__r.Meta__r.Numero_mes__c, Meta_semanal__r.Meta__r.Usuario__c FROM Meta_diaria__c WHERE Meta_semanal__r.Meta__r.Usuario__c IN: idsUser AND Meta_semanal__c IN: ids_metas_semanais];
        }else{
            metas_diarias = [SELECT Dia__c,Meta_semanal__c ,Meta_semanal__r.Valor__c,Meta_semanal__r.Inicio_da_semana__c,Meta_semanal__r.Meta__r.Ano__c, Meta_semanal__r.Meta__r.Numero_mes__c, Meta_semanal__r.Meta__r.Usuario__c FROM Meta_diaria__c WHERE Meta_semanal__r.Meta__r.Usuario__c IN: idsUser];
        }
        Map<Id, Meta_diaria__c> meta_diaria_por_id = new Map<Id, Meta_diaria__c>(metas_diarias);
        List<Opportunity> opp_usuario = [SELECT Id,CloseDate,Amount FROM Opportunity WHERE OwnerId IN: idsUser AND Stagename =: GANHO];
        Set<id> idsOpp = (new Map<Id, Opportunity>(opp_usuario)).keySet();
        List<QuoteLineItem> oppLineitem = [SELECT Id, Product2.Family, Quantity, Product2.Metragem__c,Quote.OpportunityId FROM QuoteLineItem where Quote.OpportunityId IN: idsOpp AND Product2Id != null];
        Map<Id, List<QuoteLineItem>> mapOppLineItem = new Map<Id, List<QuoteLineItem>>();
        for(QuoteLineItem item : oppLineitem){
            if(mapOppLineItem.get(item.Quote.OpportunityId) != null){
                List<QuoteLineItem> lineItens = mapOppLineItem.get(item.Quote.OpportunityId);
                lineItens.add(item);
                mapOppLineItem.put(item.Quote.OpportunityId, lineItens);
            }else{
                List<QuoteLineItem> lineItens = new List<QuoteLineItem>();
                lineItens.add(item);
                mapOppLineItem.put(item.Quote.OpportunityId, lineItens);
            }
        }
        Map<Date, Meta_diaria__c> meta_diaria_por_data = new Map<Date, Meta_diaria__c>();
        for(Meta_diaria__c meta_diaria : metas_diarias){
            meta_diaria_por_data.put(meta_diaria.Dia__c, meta_diaria);
        }
        Map<Id, List<Opportunity>> opp_by_meta_dia = new Map<Id, List<Opportunity>>();
        for(Opportunity opp : opp_usuario){
            if(meta_diaria_por_data.get(opp.CloseDate) != null){
                Meta_diaria__c meta_dia = meta_diaria_por_data.get(opp.CloseDate);
                if(opp_by_meta_dia.get(meta_dia.Id) != null){
                    List<Opportunity> opps = opp_by_meta_dia.get(meta_dia.Id);
                    opps.add(opp);
                    opp_by_meta_dia.put(meta_dia.Id, opps);
                }else{
                    List<Opportunity> opps = new List<Opportunity>();
                    opps.add(opp);
                    opp_by_meta_dia.put(meta_dia.Id, opps);
                }
            }
        }

        for(Meta_diaria__c metas_diaria : metas_diarias){
            if(opp_by_meta_dia.get(metas_diaria.Id) == null){
                opp_by_meta_dia.put(metas_diaria.Id, new List<Opportunity>());
            }
        }

        for(Id idMeta_diaria : opp_by_meta_dia.keySet()){
            Meta_diaria__c meta_diaria = meta_diaria_por_id.get(idMeta_diaria);
            meta_diaria.Valor_alcancado_do_dia__c = 0;
            meta_diaria.Andamento_protecao_pisos__c = 0;
            meta_diaria.Andamento_protecao_tubulacoes__c = 0;
            meta_diaria.Andamento_mascaramento_pintura__c = 0;
            meta_diaria.Andamento_protecao_bancadas__c = 0;
            meta_diaria.Andamento_protecao_quinas_e_batentes__c = 0;
            meta_diaria.Andamento_protecao_metais__c = 0;
            meta_diaria.Andamento_materiais_basico__c = 0;
            meta_diaria.Andamento_isolamento_ambientes__c = 0;
            for(Opportunity opp : opp_by_meta_dia.get(idMeta_diaria)){
                if(mapOppLineItem.get(opp.Id) != null){
                    for(QuoteLineItem item : mapOppLineItem.get(opp.Id)){
                        switch on item.Product2.Family{
                            when 'protecao_pisos'{
                                meta_diaria.Andamento_protecao_pisos__c += (item.Product2.Metragem__c != null) ? item.Product2.Metragem__c*item.Quantity : 0;
                            }
                            when 'protecao_tubulacao'{
                                meta_diaria.Andamento_protecao_tubulacoes__c += (item.Quantity != null) ? item.Quantity : 0;
                            }
                            when 'mascaramento_pintura'{
                                meta_diaria.Andamento_mascaramento_pintura__c += (item.Quantity != null) ? item.Quantity : 0;
                            }
                            when 'protecao_bancada'{
                                meta_diaria.Andamento_protecao_bancadas__c += (item.Quantity != null) ? item.Quantity : 0;
                            }
                            when 'protecao_quinas_batentes'{
                                meta_diaria.Andamento_protecao_quinas_e_batentes__c += (item.Quantity != null) ? item.Quantity : 0;
                            }
                            when 'protecao_metais'{
                                meta_diaria.Andamento_protecao_metais__c += (item.Quantity != null) ? item.Quantity : 0;
                            }
                            when 'Materiais Básico'{
                                meta_diaria.Andamento_materiais_basico__c += (item.Quantity != null) ? item.Quantity : 0;
                            }
                            when 'Isolamento para ambientes'{
                                meta_diaria.Andamento_isolamento_ambientes__c += (item.Quantity != null) ? item.Quantity : 0;
                            }
                        }
                    }
                }
                if(opp.Amount != null)
                    meta_diaria.Valor_alcancado_do_dia__c += opp.Amount;
                opp.Meta_semanal__c = meta_diaria.Meta_semanal__c;
                opp.Meta_diaria__c = meta_diaria.Id;
                opp_atualizar.add(opp);
            }
            metas_diarias_atualizar.add(meta_diaria);
        }
        System.debug('metas_diarias_atualizar');
        System.debug(metas_diarias_atualizar);
        System.debug('opp_atualizar');
        System.debug(opp_atualizar);
        if(metas_diarias_atualizar.size() > 0){
            update metas_diarias_atualizar;
        }
        if(opp_atualizar.size() > 0){
            update opp_atualizar;
        }
    }
	
    public static void separar_opportunidades(List<Opportunity> oppNewList, Map<Id,Opportunity> oppOldMap){
        List<Opportunity> oppList = new List<Opportunity>();
        Set<Id> idsUsuario = new Set<Id>();
        for(Opportunity opp :oppNewList){
            System.debug(opp);
            System.debug(opp.Stagename);
            if(opp.Stagename == GANHO){
                if(oppOldMap != null){
                    if(oppOldMap.get(opp.Id) != null){
                        if(oppOldMap.get(opp.Id).Stagename != GANHO || 
                        oppOldMap.get(opp.Id).Amount != opp.Amount || 
                        oppOldMap.get(opp.Id).CloseDate != opp.CloseDate || 
                        oppOldMap.get(opp.Id).OwnerId != opp.OwnerId){
                            idsUsuario.add(opp.OwnerId);
                        }
                    }
                }else{
                    idsUsuario.add(opp.OwnerId);
                }
            }
        }
		String jsonSerialize = JSON.serialize(idsUsuario) +';'+JSON.serialize(new List<Meta_semanal__c>()) ; 

        if(idsUsuario.size() > 0){
            
            atualizar_metas_usuario(jsonSerialize);
        }
    }

    public static void separar_metas(List<Meta__c> metaNewList, Map<Id,Meta__c> metaOldMap){
        List<Meta__c> metaList = new List<Meta__c>();
        for(Meta__c meta :metaNewList){
            if(metaOldMap != null){
                if(metaOldMap.get(meta.Id) != null){
                    if(metaOldMap.get(meta.Id).Valor__c != meta.Valor__c || metaOldMap.get(meta.Id).Usuario__c != meta.Usuario__c || 
                        metaOldMap.get(meta.Id).Ano__c != meta.Ano__c || metaOldMap.get(meta.Id).Numero_mes__c != meta.Numero_mes__c){
                        metaList.add(meta);
                    }
                }
            }else
                metaList.add(meta);
        }
        if(metaList.size() > 0){
            criar_metas_semanais(metaList);
        }
    }

    public static void atualizaNome(List<Meta__c> metas){
        Set<Id> idsUsuario = new Set<Id>();
        for(Meta__c meta : metas){
            idsUsuario.add(meta.Usuario__c);
        }
        Map<Id, User> mapUsuario = new Map<Id, User>([SELECT Name from User WHERE Id IN: idsUsuario]);
        for(Meta__c meta : metas){
            meta.Name = meta.Mes__c+' de '+meta.Ano__c+' - '+mapUsuario.get(meta.Usuario__c).Name;
        }
    }

    public static Boolean dia_nao_util(Date data, BusinessHours bh){
        String dia = Datetime.newInstance(data.year(), data.month(), data.day(), 0, 0, 0).format('E');
        Boolean dia_nao_util = (dia == 'Sat' || dia == 'Sun');
        if(!dia_nao_util){
            Datetime checkDatetime = Datetime.newInstance(data.year(), data.month(), data.day(), bh.MondayStartTime.hour(), bh.MondayStartTime.minute(), bh.MondayStartTime.second());
            dia_nao_util = !BusinessHours.isWithin(bh.Id,checkDateTime);
        }
        return dia_nao_util;
    }
}