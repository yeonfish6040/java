package com.springwebpractice.springweb.util;

import java.util.ArrayList;

public class Stopwatch {
	static ArrayList times = new ArrayList();
	Stopwatch(){
		
	}
	
	public static long Flag() {
		long current = System.currentTimeMillis();
		times.add(current);
		return current;
	}
	
	public static StringBuffer getTimes() {
		StringBuffer timeList = new StringBuffer();
		for(int i=0;i<times.size();i++) {
			timeList.append(times.get(i)+"\n");
		}
		return timeList;
	}
	
	public static long getTime(int i) {
		long time = (long)times.get(i);
		return time;
	}
	
	public static int remove(int i) {
		if(times.size() < i+1) return -1;
		times.remove(i);
		return 0;
	}
	
	public static void clear() {
		times.clear();
	}
	
	public static long getDuration(int i, int j) {
		if(i==j || i<0 || j<0 || times.size() < i+1 || times.size() < j+1) return -1;
		long duration;
		if(i<j) {
			duration = (long)times.get(j)-(long)times.get(i);
		}else {
			duration = (long)times.get(i)-(long)times.get(j);
		}
		return duration;
	}
}
