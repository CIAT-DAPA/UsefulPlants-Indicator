package org.ciat.control;

import java.util.LinkedHashSet;
import java.util.Set;

import org.ciat.model.Basis;
import org.ciat.model.DataSourceName;
import org.ciat.model.Utils;

public class GBIFNormalizer extends Normalizer {
	
	Set<String> issues = new LinkedHashSet<>();

	public GBIFNormalizer() {
		super();
		issues.add("COORDINATE_OUT_OF_RANGE");
		issues.add("COUNTRY_COORDINATE_MISMATCH");
		issues.add("ZERO_COORDINATE");
	}

	@Override
	public String validate() {

		String result = super.validate();

		// ignoring CWR dataset in GBIF
		if (colIndex.get("datasetkey") != null
				&& values[colIndex.get("datasetkey")].contains("07044577-bd82-4089-9f3a-f4a9d2170b2e")) {
			result += "GBIF_ALREADY_IN_CWR;";
		}

		// only allow species and subspecies
		if (colIndex.get("taxonrank") != null) {
			if (!(values[colIndex.get("taxonrank")].contains("SPECIES")
					|| values[colIndex.get("taxonrank")].contains("VARIETY"))) {
				result += "GBIF_RANK_IS_" + colIndex.get("taxonrank") + ";";
			}
		}

		for (String issue : issues) {
			if (colIndex.get("issue") != null && values[colIndex.get("issue")].contains(issue)) {
				result += "GBIF_" + issue + ";";
			}
		}

		return result;
	}


	@Override
	public Basis getBasis() {
		if (values[colIndex.get("basisofrecord")].toUpperCase().equals("LIVING_SPECIMEN")) {
			return Basis.G;
		}
		return Basis.H;
	}

	@Override
	public String getYear() {
		String year = values[colIndex.get("year")];
		return Utils.validateYear(year);
	}

	@Override
	public String getTaxonkey() {
		return values[colIndex.get("taxonkey")];
	}

	@Override
	public String getDecimalLatitude() {
		return values[colIndex.get("decimallatitude")];
	}

	@Override
	public String getDecimalLongitude() {
		return values[colIndex.get("decimallongitude")];
	}

	@Override
	public String getCountry() {
		return Utils.iso2CountryCodeToIso3CountryCode(values[colIndex.get("countrycode")]);
	}

	@Override
	public DataSourceName getDataSourceName() {
		return DataSourceName.GBIF;
	}

	@Override
	public String getSpecificSeparator() {
		return "\t";
	}
}
