//
//  CycleCode.swift
//  NetworkHW
//
//  Created by bestK1ng on 20/11/2017.
//  Copyright © 2017 bestK1ng. All rights reserved.
//

import Cocoa

typealias Polynomial = Int

/*
     Информационный вектор: 00001010001
     Код: Ц[15,11] => (n = 15, k = 11)
     Способность кода: Co
 
     Кодирование:
 
     1. m(x) = 00001010001
     m(x) = 0*x^10 + 0*x^9 + 0*x^8 + 0*x^7 + 1*x^6 + 0*x^5 + 1*x^4 + 0*x^3 + 0*x^2 + 0*x^1 + 1*x^0
     m(x) = x^6 + x^4 + 1
     m(x) * x^(n-k) = (1*x^6 + 1*x^4 + 1) * x^(15-11) = x^10 + x^8 + x^4 = 10100010000
     (тоже самое, что и m(x) << (n-k), то есть 00001010001 << 4 = 000010100010000)
 
     2. m(x) * x^(n-k) / g(x)
 
     Для Ц[15,11]) g(x) = х^4 + х + 1 = 10011
 
     Делим
     10100010000 | 10011
     10011       | 10001
     00010100
     10011
     0000100 => остаток = 0100
 
     p(x) = 100 = x^2
 
     3. v(x) = m(x) * x^(n-k) + p(x) = x^10 + x^8 + x^4 + x^2
     (тоже самое, что и m(x) + (конкатенация) g(x) = 10100010100)
 
     Декодирование:
 
     1. 10100010100 | 10011
     10011       | 1000100
     000010101
     10011
     0001000 => остаток = 1000 - вектор синдрома
 */

class CycleCodeCalculator {
    
    // Информационный вектор (m(x))
    var infoVector: Polynomial
    
    var n: Int
    var k: Int
    
    // Образующий полином (g(x))
    var formingPolynomial: Polynomial
    
    // Циклический код
    var cycleCode: Polynomial = 0
    
    // Список значений тестирования
    var range: CountableClosedRange<Int>
    
    init(infoVector: Polynomial, n: Int, k: Int) {
        
        self.infoVector = infoVector
        
        self.n = n
        self.k = k
        
        // Задание образующего полинома
        if (n, k) == (7, 4) {
            self.formingPolynomial = 0b1011
            self.range = 0b0...0b1111111
        } else if (n, k) == (15, 11) {
            self.formingPolynomial = 0b10011
            self.range = 0b0...0b111111111111111
        } else {
            self.formingPolynomial = 1
            self.range = 0b0...0b1
        }
        
        self.cycleCode = calculateCycleCode(polinomial: infoVector)
    }
    
    /*
     Вычисление циклического кода
     */
    func calculateCycleCode(polinomial: Polynomial) -> Polynomial {
        
        let shiftedPolynomial = polinomial << (n-k)
        let modulo = binaryXorModulo(dividend: shiftedPolynomial, divider: formingPolynomial)
        
        return shiftedPolynomial + modulo
    }
    
    /*
     Получение вектора ошибки
     */
    func getErrorCode(polinomial: Polynomial) -> Polynomial {
        
        let error = binaryXorModulo(dividend: polinomial, divider: formingPolynomial)

        return error
    }
    
    /*
     Вычисление обнаруживающих способностей в таблице
     */
    func calculateDetectingAbilitiesInTable() -> [TableRow] {
        
        var table: [TableRow] = []
        for i in 1...n {
            
            let row = TableRow()
            row.value = i
            
            table.append(row)
        }
        
        for value in range {
            
            var k = 0
            var n = 0
            
            let valueBits = binaryArrayFromValue(value, needToSupplement: true)
            let cycleBits = binaryArrayFromValue(self.cycleCode, needToSupplement: true)
            
            while k < valueBits.count {
                if cycleBits[k] != valueBits[k] {
                    n += 1
                }
                k += 1
            }
            
            let error = getErrorCode(polinomial: value)
            
            if n == 0  {
                continue
            }

            table[n-1].combinationsCount += 1
            if error != 0 {
                // ошибка
                table[n-1].errorsCount += 1
            }
        }
        
        for row in table {
            
            if row.combinationsCount == 0, row.errorsCount == 0 {
                row.detectingAbility = 1
            } else {
                row.detectingAbility = Double(row.errorsCount) / Double(row.combinationsCount)
            }
        }
        
        return table
    }
    
    // MARK: Helpers
    
    /*
     Преобразование числа в массив битов
     */
    func binaryArrayFromValue(_ value: Int, needToSupplement: Bool = false) -> [Int] {
        
        let string = String(value, radix: 2)
        
        var bits: [Int] = []
        for char in string {
            let bit = Int(String(char))!
            bits.append(bit)
        }
        
        if needToSupplement {
            while bits.count < n {
                bits.insert(0, at: 0)
            }
        }
        
        return bits
    }
    
    /*
     Преобразования массива битов в число
     */
    func valueFromBinaryArray(_ binaryArray: [Int]) -> Int {
        
        var value = 0
        
        for i in 0..<binaryArray.count {
            if binaryArray[i] == 1 {
                value += Int(pow(Double(2), Double(binaryArray.count - 1 - i)))
            }
        }
        
        return value
    }
    
    /*
     Нахождения остатка от специального XOR деления
     */
    func binaryXorModulo(dividend: Polynomial, divider: Polynomial) -> Polynomial {
        
        var dividend = binaryArrayFromValue(dividend, needToSupplement: true)
        let divider = binaryArrayFromValue(divider)
                
        var modulo = 0
        
        while dividend.count >= divider.count {
            
            // c = a // b
            let a = Array(dividend[0...(divider.count-1)])
            let b = divider
            let c = binaryArrayFromValue((valueFromBinaryArray(a) ^ valueFromBinaryArray(b)))
            
            // Удаление ненужных битов из делимого
            for _ in 0..<divider.count {
                dividend.remove(at: 0)
            }

            // Создание нового делимого
            dividend = c + dividend
            
            // Сохранение остатка
            modulo = valueFromBinaryArray(dividend)
        }
        
        return modulo
    }
}
