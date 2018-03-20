//import LandmarkParticleSet from './landmark-particle-set';
//ported from https://github.com/wouterbulten/slacjs/blob/e21748e5c11f1eb6357dc528bc60a4645ff09e22/src/app/models/landmark-init-set.js

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

class LandmarkInitializationSet {
  private int nParticles, stdRange, randomParticles;
  private double effectiveParticleThreshold, maxVariance;
  private Map<String, LandmarkParticleSet> particleSetMap;
  
  /**
   * Set containing multiple particle sets for initalisation of landmarks
   * @param  {Number} nParticles                 Number of particles in each set
   * @param  {Number} stdRange                   sd of range measurements
   * @param  {Number} randomParticles            Number of random particles
   * @param  {Number} effectiveParticleThreshold Threshold of effective particles
   * @param  {Number} maxVariance
   * @return {LandmarkInitializationSet}
   */
  public LandmarkInitializationSet(SlacConfiguration slacConfig) {
    this.nParticles = slacConfig.getParticles().getN();
    this.stdRange = slacConfig.getParticles().getSd();
    this.randomParticles = slacConfig.getParticles().getRandomN();
    this.maxVariance = slacConfig.getParticles().getMaxVariance();

    if (this.effectiveParticleThreshold == 0) {
      this.effectiveParticleThreshold = nParticles / 1.5;
    }
    else {
      this.effectiveParticleThreshold = slacConfig.getParticles().getEffectiveParticleThreshold();
    }

    this.particleSetMap = new HashMap();
  }

  /**
   * Integrate a new measurement
   * @param {String} uid UID of landmark
   * @param {Number} x   Position of user
   * @param {Number} y   Position of user
   * @param {Number} r   Range measurement
   */
  public LandmarkInitializationSet addMeasurement(String uid, double x, double y, double r) {
    if (!this.has(uid)) {
      this.particleSetMap.put(uid, new LandmarkParticleSet(
        this.nParticles, this.stdRange, this.randomParticles, this.effectiveParticleThreshold, this.maxVariance
      ));
    }

    this.particleSetMap.get(uid).addMeasurement(x, y, r);

    return this;
  }

  /**
   * Returns true when there is a particle set for a landmark
   * @param  {String}  uid
   * @return {Boolean}
   */
  public boolean has(String uid) {
    return this.particleSetMap.containsKey(uid);
  }

  /**
   * Returns best position estimate for a landmark
   * @param  {String} uid
   * @return {Object}
   */
  public PositionEstimate estimate(String uid) {
    return this.particleSetMap.get(uid).positionEstimate();
  }

  /**
   * Remove a particle set
   * @param  {String} uid
   * @return {void}
   */
  public void remove(String uid) {
    this.particleSetMap.remove(uid);
  }

  /**
   * Return all particle sets
   * @return {Array}
   */
  public List<LandmarkParticleSet> particleSets() {
    return new ArrayList(this.particleSetMap.values());
  }
}