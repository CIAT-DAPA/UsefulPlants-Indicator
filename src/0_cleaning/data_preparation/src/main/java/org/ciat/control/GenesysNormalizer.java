package org.ciat.control;



import org.ciat.model.Basis;
import org.ciat.model.DataSourceName;
import org.ciat.model.TaxonFinder;
import org.ciat.model.Utils;

public class GenesysNormalizer extends Normalizer {


	@Override
	public String validate() {

		String result = super.validate();
		
		
		return result;
	}

	@Override
	public String getDecimalLatitude() {
		return values[colIndex.get("g.latitude")];
	}

	@Override
	public String getDecimalLongitude() {
		return values[colIndex.get("g.longitude")];
	}

	@Override
	public String getCountry() {
		String country = Utils.iso3CountryCodeToIso2CountryCode(values[colIndex.get("a.orgCty")]);
		country = Utils.iso2CountryCodeToIso3CountryCode(country);
		return country;
	}

	@Override
	public DataSourceName getDataSourceName() {
		return DataSourceName.GENESYS;
	}

	@Override
	public Basis getBasis() {
		return Basis.G;
	}

	@Override
	public String getYear() {
		String year = values[colIndex.get("a.acqDate")];
		return Utils.validateYear(year);
	}

	@Override
	public String getTaxonkey() {
		return TaxonFinder.getInstance().fetchTaxonKey(values[colIndex.get("t.taxonName")]);
	}
	
	@Override
	public String getSpecificSeparator() {
		return ",";
	}
	

}
