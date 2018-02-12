package org.ciat.model;

import java.io.File;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Locale;
import java.util.Map;

public class Utils {

	private static Map<String, Locale> localeMap = initCountryCodeMapping();

	public static boolean isNumeric(String str) {
		if (str == null) {
			return false;
		}
		try {
			@SuppressWarnings("unused")
			double d = Double.parseDouble(str);
		} catch (NumberFormatException nfe) {
			return false;
		}
		return true;
	}

	public static Map<String, Integer> getColumnsIndex(String line, String separator) {
		Map<String, Integer> colIndex = new LinkedHashMap<String, Integer>();
		String[] columnNames = line.split(separator);
		for (int i = 0; i < columnNames.length; i++) {
			colIndex.put(columnNames[i], i);
		}
		return colIndex;
	}

	public static boolean areValidCoordinates(String decimallatitude, String decimallongitude) {
		if (!isNumeric(decimallatitude)) {
			return false;
		} else {
			Double lat = Double.parseDouble(decimallatitude);
			if (lat == 0 || lat > 90 || lat < -90) {
				return false;
			}
		}
		if (!isNumeric(decimallongitude)) {
			return false;
		} else {
			Double lat = Double.parseDouble(decimallongitude);
			if (lat == 0 || lat > 180 || lat < -180) {
				return false;
			}
		}
		return true;
	}

	private static Map<String, Locale> initCountryCodeMapping() {
		String[] countries = Locale.getISOCountries();
		Map<String, Locale> localeMap = new HashMap<String, Locale>(countries.length);
		for (String country : countries) {
			Locale locale = new Locale("", country);
			localeMap.put(locale.getISO3Country().toUpperCase(), locale);
		}
		return localeMap;
	}

	public static String iso3CountryCodeToIso2CountryCode(String iso3CountryCode) {
		if (localeMap.get(iso3CountryCode) != null) {
			return localeMap.get(iso3CountryCode).getCountry();
		}
		return null;
	}

	public static String iso2CountryCodeToIso3CountryCode(String iso2CountryCode) {
		if(iso2CountryCode.equals("ZZ")){
			return null;
		}
		Locale locale = new Locale("", iso2CountryCode);
		try {
			String result = locale.getISO3Country();
			return result;
		} catch (Exception e) {
			return null;
		}
	}

	public static void clearOutputDirectory(File outputDir) {
		if (outputDir.exists()) {
			for (File f : outputDir.listFiles()) {
				f.delete();
			}
		} else {
			outputDir.mkdir();
		}
	}
}
