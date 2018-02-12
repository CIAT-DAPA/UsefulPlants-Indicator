package org.ciat.view;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Properties;

public class Executer implements Executable {
	private static DateFormat dateFormat = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
	
	private Date startDate;
	public static File config = new File("config.properties");
	public static Properties prop = obtainProperties();
	
	public Executer() {
		this.startDate = new Date();
	}
	

	public static void log(String message) {
		System.out.println();
		System.out.println(getTimestamp() + " " + message);
	}

	public static String getTimestamp() {
		Date date = new Date();
		return dateFormat.format(date);
	}

	@Override
	public void run() {
		
		
	}
	
	private static Properties obtainProperties() {
		Properties prop = new Properties();
		if (config.exists()) {
			try (FileInputStream in = new FileInputStream(config.getName())) {
				prop.load(in);

			} catch (IOException e) {
				System.out.println(config + "not found");
			} catch (Exception e) {
				System.out.println("Error reading configuration in file, please check the format");
			}

			return prop;

		} else {
			System.out.println("Configuration not found in: " + config.getAbsolutePath());
		}

		return prop;
	}


	public Date getStartDate() {
		return startDate;
	}


}
