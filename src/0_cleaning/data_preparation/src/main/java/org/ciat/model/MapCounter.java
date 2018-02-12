package org.ciat.model;

import java.util.TreeMap;

public class MapCounter extends TreeMap<String, Integer> {

	private static final long serialVersionUID = 7814812026431351180L;

	public void increase(String key) {
		if (this.containsKey(key)) {
			this.put(key, this.get(key) + 1);
		} else {
			this.put(key, new Integer(1));
		}
	}

}
