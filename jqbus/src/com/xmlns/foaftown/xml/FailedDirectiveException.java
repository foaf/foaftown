/* 	
 * 
 *    Copyright 2004 Ian Sollars
 * 
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 * 
 *        http://www.apache.org/licenses/LICENSE-2.0
 * 
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 *
 * Created on Apr 11, 2004, 3:56:12 PM by Ian
 *
 */
//package net.ex_337.gradient;

package com.xmlns.foaftown.xml;

/**
 * @author Ian
 *
 */
public class FailedDirectiveException extends EngineException {
	
	public static final long serialVersionUID = 000;// danbri added
	
	/**
	 * @param s
	 */
	public FailedDirectiveException(String s) {
		super(s);
	}
	/**
	 * @param t
	 */
	public FailedDirectiveException(Throwable t) {
		super(t);
	}
	/**
	 * @param s
	 * @param t
	 */
	public FailedDirectiveException(String s, Throwable t) {
		super(s, t);
	}
}
