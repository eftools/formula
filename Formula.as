package
{
	import inobr.eft.formula.core.*;
	import inobr.eft.formula.core.checkers.*;
	import inobr.eft.formula.elements.functions.*;
	import inobr.eft.formula.elements.main.*;
	import inobr.eft.formula.lang.ru;
	
	/**
	 * ...
	 * 
	 * @author Peter Gerasimenko <gpstmp@gmail.com>
	 */
	[SWF(width = "550", height = "400", frameRate = "40", backgroundColor = "#729FDC")]
	public class Formula extends Initializer
	{	
		override protected function initialize():void 
		{	
			var workspace:FormulaWorkspace = new FormulaWorkspace(530, 380, ru);
			workspace.y = 10;
			
			workspace.toolbar.addCategoryByParams(new CommonCategoryButton(), [Fraction, Power, Brackets, Root]);
			workspace.toolbar.addCategoryByParams(new FunctionsCategoryButton(), [Sinus, Cosinus, Tangent, Cotangent, NaturalLogarithm, Logarithm]);
			workspace.toolbar.addCategoryByParams(new VariableCategoryButton(), [Variable.getToolbarItem("k", [-3, -2, 0, 1]), Variable.getToolbarItem("Fтр", 2)]);
			
			workspace.formulaAreaType = FormulaAreaTypes.CHECK;
			
			workspace.addChecker(new CheckByValues([1, 0, 4, 9]));
			workspace.addChecker(new CheckByNumericTokens(2, 4));
			
			addChild(workspace);
		}
		
	}

}