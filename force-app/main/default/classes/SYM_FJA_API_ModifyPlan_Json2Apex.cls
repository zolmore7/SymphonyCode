public class SYM_FJA_API_ModifyPlan_Json2Apex {
	public class Domains {
		public Percentage percentage;
        public IndivMax indivMax;
	}

	public String name;
	public String proxyId;
	public String planId;
	public String effectiveDate;
	public List<AttachedPlans> attachedPlans;

	public class ContinuousEntries {
		public Double min;
		public Double max;
		public Double increment;
		public Unit unit;
		public String rawUnit;
	}

	public class Percentage {
		public List<ContinuousEntries> continuousEntries;
		public DiscreteValues discreteValues;
	}
    
    public class IndivMax {
		public List<ContinuousEntries> continuousEntries;
		public DiscreteValues discreteValues;
	}

	public class Accumulators {
		public String accumulatorName;
		public String accumulatorDisplayName;
		public Double value;
		public String benefitPeriod;
		public Boolean applyToXrefAccum;
		public String fullPath;
		public Domains domains;
		public Double indivMax;
	}

	public class DiscreteValues {
	}

	public class AttachedPlans {
		public String proxyId;
		public String templateProxyId;
		public PlanHeader planHeader;
		public List<Accumulators> accumulators;
		public List<DiscreteValues> compactViews;
	}

	public class Unit {
		public String acronym;
		public String name;
		public String shortText;
	}

	public class PlanHeader {
		public String networkVariation;
	}

	
	public static List<SYM_FJA_API_ModifyPlan_Json2Apex> parse(String json) {
		return (List<SYM_FJA_API_ModifyPlan_Json2Apex>) System.JSON.deserialize(json, List<SYM_FJA_API_ModifyPlan_Json2Apex>.class);
	}
}