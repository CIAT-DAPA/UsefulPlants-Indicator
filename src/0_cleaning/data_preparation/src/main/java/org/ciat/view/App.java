package org.ciat.view;


public class App {

	public static void main(String[] args) {
		
		Executable app1 = new ExecNormalizer();
		app1.run();
		Executable app2 = new ExecNativeness();
		app2.run();
		Executable app3 = new ExecMaxentnisizer();
		app3.run();

	}

}
