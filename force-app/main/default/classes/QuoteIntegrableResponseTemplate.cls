public class QuoteIntegrableResponseTemplate{
    /*public Double BASE_ICMS;	//612.48
public Double VL_COFINS;	//15.07
public Double VL_ICMS;	//110.25
public Double VALOR_NF;	//612.48
public Double VALPS2;	//3.26
public Double BASE_CALC;	//612.48*/
    
    public cls_produtos[] produtos;
    public class cls_produtos {
        public cls_impostos impostos;
        public Integer item;	//1
        public String produto;	//8301400004
    }
    public class cls_impostos {
        public Double BASE_ICMS;	//109.9
        public Double VL_COFINS;	//2.7
        public Double VL_ICMS;	//19.78
        public Double VALOR_NF;	//109.9
        public Double VALPS2;	//0.59
        public Double BASE_CALC;	//109.9
        public Double ICMS_SOL;	//109.9
    }
    
}