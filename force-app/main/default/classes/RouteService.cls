public class RouteService {
    List<maps__Waypoint__c> routeNewList;
    List<maps__Waypoint__c> routeOldList;
    Map<Id, maps__Waypoint__c> routeNewMap;
    Map<Id, maps__Waypoint__c> routeOldMap;

    public RouteService(List<maps__Waypoint__c> routeNewList, List<maps__Waypoint__c> routeOldList, Map<Id, maps__Waypoint__c> routeNewMap, Map<Id, maps__Waypoint__c> routeOldMap) {
        if (routeOldList == null) routeOldList = new List<maps__Waypoint__c>();
        if (routeNewMap == null) routeNewMap = new Map<Id, maps__Waypoint__c>();
        this.routeNewList = routeNewList;
        this.routeOldList = routeOldList;
        this.routeNewMap = routeNewMap;
        this.routeOldMap = routeOldMap;
    }
    public void generateOC() {
        Set<Id> routeSet = new Set<Id>();
        Set<Id> markerLayerSet = new Set<Id>();

        Map<Id, OrdemCarregamento__c> ordemCarregamentoMap = new Map<Id, OrdemCarregamento__c>();
        Map<String, OrdemCarregamento__c> ordemCarregamentoMapToInsert = new Map<String, OrdemCarregamento__c>();
        List<OrdensCarregamentoPedido__c> ordemCarregamentoPedidoToInsert = new List<OrdensCarregamentoPedido__c>();
        Map<String, Map<String,maps__Waypoint__c>> waypoinsMap = new Map<String, Map<String,maps__Waypoint__c>>();

        for (maps__Waypoint__c maps : this.routeNewList) {
            routeSet.add(maps.maps__Route__c);
            markerLayerSet.add(maps.maps__MarkerLayer__c);
            if (waypoinsMap.containsKey(maps.maps__Route__c)) {
                Map<String,maps__Waypoint__c> route = waypoinsMap.get(maps.maps__Route__c);
                route.put(String.valueOf(maps.maps__SortOrder__c), maps);
                waypoinsMap.put(maps.maps__Route__c, route);
            }else{
                Map<String,maps__Waypoint__c> route = new Map<String, maps__Waypoint__c>();
                route.put(String.valueOf(maps.maps__SortOrder__c), maps);
                waypoinsMap.put(maps.maps__Route__c, route);
            }
        }
        Map<Id,maps__MarkerLayer__c> selectMarkerMap = new Map<Id,maps__MarkerLayer__c>([SELECT Id, Name FROM maps__MarkerLayer__c WHERE Id IN :markerLayerSet]);
        System.debug('@@@@selectMarkerMap . . . ' + selectMarkerMap);

        Map<Id, maps__Route__c> routeMap = new Map<Id, maps__Route__c>([SELECT Id, Name,maps__Date__c FROM maps__Route__c WHERE Id IN :routeSet ]);

        List<OrdemCarregamento__c> ocList = [SELECT Id, Name, MapsRoute__c FROM OrdemCarregamento__c WHERE MapsRoute__c IN :routeSet];

        /*for (OrdemCarregamento__c ordemCarregamento : ocList) {
            ordemCarregamentoMap.put(ordemCarregamento.MapsRoute__c, ordemCarregamento);
        }*/
        for (maps__Waypoint__c maps : this.routeNewList) {
            System.debug('@@@@maps . . . ' + selectMarkerMap.get(maps.maps__MarkerLayer__c));
            maps__Route__c route = routeMap.get(maps.maps__Route__c);
            if (!ordemCarregamentoMap.containsKey(maps.maps__Route__c)
                 && maps.maps__MarkerLayer__c != null 
                 && selectMarkerMap.get(maps.maps__MarkerLayer__c).Name.substring(0,2).toUpperCase() == 'OC') {
                    ordemCarregamentoMapToInsert.put(maps.maps__Route__c, new OrdemCarregamento__c(
                            MapsRoute__c = maps.maps__Route__c,
                            DataCarregamento__c = route.maps__Date__c
                    ));
            }
        }

        if (ordemCarregamentoMapToInsert.values().size() > 0) {
            insert ordemCarregamentoMapToInsert.values();
        }
        ocList = [SELECT Id, Name, MapsRoute__c FROM OrdemCarregamento__c WHERE MapsRoute__c IN :routeSet];

        List<OrdemCarregamentoEvt__e> receiveDirectcallList  = new List<OrdemCarregamentoEvt__e>();
        List<OrdemCarregamento__c> ordemCarregamentoToUpdate = new List<OrdemCarregamento__c>();
        for (OrdemCarregamento__c ordemCarregamento : ocList) {
            String mapsRoute = '';
            ordemCarregamentoMap.put(ordemCarregamento.MapsRoute__c, ordemCarregamento);
            receiveDirectcallList.add(new OrdemCarregamentoEvt__e(ObjectId__c = ordemCarregamento.Id));
            System.debug('@@@@waypoinsMap.get(ordemCarregamento.MapsRoute__c) . .. ' + waypoinsMap.get(ordemCarregamento.MapsRoute__c));
            Map<String, maps__Waypoint__c> waypointMap = waypoinsMap.get(ordemCarregamento.MapsRoute__c);
            mapsRoute = 'https://www.google.com/maps/dir/?api=1&origin='+ EncodingUtil.urlEncode(waypointMap.get('1').maps__Address__c, 'UTF-8')
                        +'&destination='+EncodingUtil.urlEncode(waypointMap.get(String.valueOf(waypointMap.values().size())).maps__Address__c, 'UTF-8')
                        +'&travelmode=driving&waypoints=';

            for (maps__Waypoint__c mapsWaiypoint : waypointMap.values()){
                if (mapsWaiypoint.Name != 'Ponto Inicial' && String.valueOf(mapsWaiypoint.maps__SortOrder__c) != String.valueOf(waypointMap.values().size())) {
                    mapsRoute +=  '%7C' +  EncodingUtil.urlEncode(mapsWaiypoint.maps__Address__c,'UTF-8');
                }
            }
            ordemCarregamento.RotaMaps__c = mapsRoute.replaceAll(' ', '%20');
            ordemCarregamentoToUpdate.add(ordemCarregamento);
        }
        if(ordemCarregamentoToUpdate.size() > 0){
            update  ordemCarregamentoToUpdate;
        }
        System.debug('@@@@receiveDirectcallList . . . ' + receiveDirectcallList);
        List<Database.SaveResult> receiveDirectcallResults = EventBus.publish(receiveDirectcallList);
        Set<String> orderId = new Set<String>();
        for (maps__Waypoint__c maps : this.routeNewList) {
            orderId.add(maps.maps__LinkId__c);
        }
        Map<Id, Order> orderMap = new Map<Id, Order>([SELECT Id, CubagemTotal__c, QuantidadeTotal__c, TotalAmount,FilialFaturamento__c FROM Order WHERE Id IN :orderId ]);
        System.debug(orderMap);
        Map<Id,OrdemCarregamento__c> ordemCarregamentoToUpdateMap  = new Map<Id,OrdemCarregamento__c>();
        for (maps__Waypoint__c maps : this.routeNewList) {
            maps__Route__c route = routeMap.get(maps.maps__Route__c);
            if (ordemCarregamentoMap.containsKey(maps.maps__Route__c) && maps.Name != 'Ponto Inicial'
            && maps.maps__MarkerLayer__c != null 
            && selectMarkerMap.get(maps.maps__MarkerLayer__c).Name.substring(0,2).toUpperCase() == 'OC') {
                Order order = orderMap.get(maps.maps__LinkId__c);
                OrdemCarregamento__c ordemCarregamento = ordemCarregamentoMap.get(maps.maps__Route__c);
                ordemCarregamentoPedidoToInsert.add(new OrdensCarregamentoPedido__c(
                        Name                   = ordemCarregamento.Name + ' - ' + maps.Name,
                        Pedido__c              = maps.maps__LinkId__c,
                        OrdemCarregamento__c   = ordemCarregamento.Id,
                        PedidoId__c            = maps.maps__LinkId__c,
                        PosicaoCarregamento__c = Integer.valueOf(maps.maps__SortOrder__c) - 1,
                        CubagemTotal__c = order != null ? order.CubagemTotal__c : 0,
                        QuantidadeTotal__c = order != null ? order.QuantidadeTotal__c : 0,
                        ValorTotal__c = order != null ? order.TotalAmount : 0

                ));
                if (order != null && !ordemCarregamentoToUpdateMap.containsKey(ordemCarregamento.Id)) {
                    ordemCarregamento.FilialFaturamento__c = order.FilialFaturamento__c;
                    ordemCarregamentoToUpdateMap.put(ordemCarregamento.Id,ordemCarregamento);
                }
            }
        }
        if (ordemCarregamentoPedidoToInsert.size() > 0) {
            update ordemCarregamentoToUpdateMap.values();
            insert ordemCarregamentoPedidoToInsert;
        }


    }
}