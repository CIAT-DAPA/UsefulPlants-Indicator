package org.ciat.view;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;

import org.ciat.control.NativenessMarker;
import org.ciat.control.Normalizer;

public class ExecNativeness extends Executer {

	public static void main(String[] args) {
		Executable app = new ExecNativeness();
		app.run();
	}

	public void run() {

		log("Marking nativeness");
		File normalized = new File(Executer.prop.getProperty("file.normalized"));
		File nativenessed = new File(Executer.prop.getProperty("file.native"));
		try (PrintWriter writer = new PrintWriter(new BufferedWriter(new FileWriter(nativenessed)))) {
			String header = Normalizer.getHeader() + Normalizer.getStandardSeparator() + "origin";
			writer.println(header);
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}

		NativenessMarker nativenessMarker = new NativenessMarker();
		nativenessMarker.process(normalized, nativenessed);
		System.gc();

	}

}
