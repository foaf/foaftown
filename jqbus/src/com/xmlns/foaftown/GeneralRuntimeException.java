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
 */
//package net.ex_337;
package com.xmlns.foaftown.xml; 
/**
 * 
 * Generic RuntimeException subclass. This is thrown in place of a normal RuntimeException
 * 
 * @author Ian
 */
public class GeneralRuntimeException extends RuntimeException {
	public static final long serialVersionUID = 000;// danbri added
	/**
	 * Default constructor, does super.
	 * @param s
	 */
	public GeneralRuntimeException (String s) {
		super(s);
	}

	/**
	 * Default constructor, does super.
	 * @param t
	 */
	public GeneralRuntimeException (Throwable t) {
		super(t);
	}

	/**
	 * Default constructor, does super.
	 * @param s
	 * @param t
	 */
	public GeneralRuntimeException (String s, Throwable t) {
		super(s, t);
	}
}
