package org.ciat.control;

import java.util.LinkedHashSet;
import java.util.Set;

import org.ciat.model.Basis;
import org.ciat.model.DataSourceName;
import org.ciat.model.Utils;

public class GBIFNormalizer extends Normalizer {


	@Override
	public boolean isUseful() {
		
		// ignoring CWR dataset in GBIF
		if (colIndex.get("datasetkey") != null
				&& values[colIndex.get("datasetkey")].contains("07044577-bd82-4089-9f3a-f4a9d2170b2e")) {
			return false;
		}

		// only allow species and subspecies
		if (colIndex.get("taxonrank") != null) {
			if (!values[colIndex.get("taxonrank")].contains("SPECIES")) {
				return false;
			}
		}

		String country = Utils.iso2CountryCodeToIso3CountryCode(values[colIndex.get("countrycode")]);
		if (country == null) {
			return false;
		}

		Set<String> issues = new LinkedHashSet<>();
		issues.add("COORDINATE_OUT_OF_RANGE");
		issues.add("COUNTRY_COORDINATE_MISMATCH");
		issues.add("ZERO_COORDINATE");
		for (String issue : issues) {
			if (colIndex.get("issue") != null && values[colIndex.get("issue")].contains(issue)) {
				return false;
			}
		}

		if (!Utils.areValidCoordinates(values[colIndex.get("decimallatitude")],
				values[colIndex.get("decimallongitude")])) {
			return false;
		}

		Basis basis = getBasis();
		String year = values[colIndex.get("year")];
		year = Utils.validateYear(year);
		if (!year.equals(Utils.NO_YEAR)) {
			if (basis.equals(Basis.H) && Integer.parseInt(year) < Normalizer.YEAR_MIN) {
				return false;
			}
		}

		return true;
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
		return  Utils.iso2CountryCodeToIso3CountryCode(values[colIndex.get("countrycode")]);
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
