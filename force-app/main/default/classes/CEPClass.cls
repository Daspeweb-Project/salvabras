public class CEPClass {
	public String cep;
	public String logradouro;
	public String complemento;
	public String bairro;
	public String localidade;
	public String uf;
	public String ibge;
	public String gia;
	public String ddd;
	public String siafi;
	public static CEPClass parse(String json){
		return (CEPClass) System.JSON.deserialize(json, CEPClass.class);
	}
}