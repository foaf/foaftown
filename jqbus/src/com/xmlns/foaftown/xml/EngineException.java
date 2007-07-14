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
 * Created on Apr 11, 2004, 4:11:39 PM by Ian
 *
 */
package com.xmlns.foaftown.xml; // moved package; check ok w/ license
				// or put these in a .jar?

//import net.ex_337.GeneralRuntimeException;

/**
 * @author Ian
 *
 */
public class EngineException extends GeneralRuntimeException {
	
	public static final long serialVersionUID = 000;// danbri added
	/**
	 * @param s
	 */
	public EngineException(String s) {
		super(s);
	}
	/**
	 * @param t
	 */
	public EngineException(Throwable t) {
		super(t);
	}
	/**
	 * @param s
	 * @param t
	 */
	public EngineException(String s, Throwable t) {
		super(s, t);
	}
}
