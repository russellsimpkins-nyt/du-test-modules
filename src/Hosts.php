<?php

namespace Codeception\Module;
use Codeception\Configuration;
use Rust\HTTP\CurlRequest;

/**
 * This module exists to get us the hostnames we will use to run
 * acceptance tests with.
 */
class Hosts extends \Codeception\Module
{
    // here is where you can list any fields you require to be set in the yaml file
    protected $requiredFields = ['internal-cluster-code', 'partner-cluster-code'];
    protected $config = array();

   /**
    * Get the hosts on nimbul2
    */
    public function getHosts($env, $tag)
    {
        $hosts = array();
        $c     = new CurlRequest();
        $r     = $c->restCall("http://cloudhosts.prd.use1.nytimes.com/svc/cloudhosts/v1/ec2/$env/tags/server/$tag");
        if (!empty($r[200])) {
            $items  = $r[200];
            $keys   = array_keys($items);
            $hosts  = array();
            foreach ($keys as $key) {
                // only test on running instances
                if ($items[$key]['state']['name'] == "running") {
                    $hosts[] = $items[$key]['publicDnsName'];
                }
            }
        }
        return $hosts;
    }

    /**
     * Get the hosts on nimbul3
     */
    public function getN3Hosts($env, $name)
    {
        $hosts = array();
        $c     = new CurlRequest();
        $r     = $c->restCall("https://nimbul-fe.prd.nytimes.com/api/v1/instances", "GET", null, array("Authorization: Token token=" . $this->config['token']) );
        if (!empty($r[200])) {
            $items  = $r[200];
            $hosts  = array();
            foreach ($items as $item) {
                // only test on running instances
                if ($item['environment_code'] == $env && $item['cluster_code'] == $name) {
                    $hosts[] = $item['fqdn'];
                }
            }
        } else {
            $hosts = $r;
        }
        return $hosts;
    }

    
    public function getInternalHosts()
    {
        $env = $this->config['env'];
        $tag = $this->config['internal-cluster-code'];
        if (file_exists('/etc/DU_IMAGE')) {
            return $this->getHosts($env, $tag);
        }
        return $this->getN3Hosts($env, $tag);
    }

    public function getPartnerHosts()
    {
        $env = $this->config['env'];
        $tag = $this->config['partner-cluster-code'];
        if (file_exists('/etc/DU_IMAGE')) {
            return $this->getHosts($env, $tag);
        }
        return $this->getN3Hosts($env, $tag);
    }

    public function getInternalHost($data="")
    {
        return ($this->config['internal-host-header']);
    }

    public function getPartnerHost()
    {
        return ($this->config['partner-host-header']);
    }

    public function getWwwHost()
    {
        return ($this->config['www-host-header']);
    }
    
    public function getHost()
    {
        $host = getenv('TEST_HOST');
        if (!empty($host)) {
            return $host;
        }
        return "";
    }
    
    public function getHeader()
    {
        $header = getenv('TEST_HEADER');
        if (!empty($header)) {
            return $header;
        }
        return "";
    }
}
