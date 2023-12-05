def bayes_filter(cdm_df, cdm_perception_model):
    """ The bayesian filter accumulates CDMs as they come using action models of satellites
        and updatable perception models of CDM service providers. 
        
        :param:cdm_df: List of CDMS for sat1 and sat2
        :param:sat_action_model: list of minimum sufficient tuples for each class of actions
          for example with event is_colliding == is_co
         [(p(is_co | do_nothing, is_co), p(is_co | do_nothing, is_not_co)),
          (p(is_co | do_maneuver, is_co), p(is_co | do_nothing, is_not_co))]
        :param:cdm_perception_model: list of minimum sufficient tuples for each class of actions
          for example with event is_colliding == is_co
         [(p(is_co | is_co), p(is_co | is_not_co))]
    """
    prior_col = -1
    prior_nocol = -1
    pred_col = -1
    pred_nocol = -1
    
    for k,cdm in cdm_df.iterrows():
        print(k)
        if prior_col == -1:
            # First observation is our prior
            # Time period taken randomly forces the first provider of CDMs to be randomly picked
            prior_col = cdm[probability_col]
            print(f"Prior proba = {prior_col}")
            
            if prior_col is None or np.isnan(prior_col):
                print("Not a valid prior.")
                break
            prior_nocol = 1.0 - prior_col
            
            print(" --- ")
            continue
            
        # Service Provider (only one for prototype)
        # TODO get provider name from cdm info
        SP = "PROVIDER_1"
        
        pred_col = cdm_perception_model[SP][0] * prior_col
        pred_nocol = cdm_perception_model[SP][1] * prior_nocol
        
        # normalizer 
        nzr = 1.0  / (pred_col + pred_nocol)
        
        # applying normalization
        pred_col = nzr * pred_col
        pred_nocol = nzr * pred_nocol
        
        print(f"Collision prediction becomes {pred_col}")
        print(f"No Collision prediction becomes {pred_nocol}")
        
        # Keeping last prediction as next prior
        prior_col = pred_col
        prior_nocol = pred_nocol 
        
            
            

def cdm_consensus(sat1="PREDEFINED", sat2="PREDEFINED"):
    """
        Create consensus for CDMs between sat1 and sat2
       
        :param:sat1: ID or string name: Do not use - defined randomly
        :param:sat2: ID or string name: Do not use - defined randomly
    """
    S = api_get_any_pairs_cdms()
    print(f"Computing CDM consensus between {S[0]} and {S[1]}")
    cdm_df = api_get_cdm_list(S[0], S[1])
    
    # Add perception model to augmented cdm dataframe.
    # 0.8 collision if collision (thus 0.2 not collision if collision)
    # 0.9 not collision if not collision (thus 0.1 collision if not collision)
    cdm_perception_model = {"PROVIDER_1":(0.8, 0.9)}
    
    return bayes_filter(cdm_df, cdm_perception_model)
